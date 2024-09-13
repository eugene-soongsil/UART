/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xscugic.h"

#define XPAR_FABRIC_UART_TOP_0_IRQREQ_INTR 61U

XScuGic InterruptController; /* Instance of the Interrupt Controller */
static XScuGic_Config *GicConfig; /* The configuration parameters of the
 controller */
void DeviceDriverHandler(void *CallbackRef);

/*
 * Create a shared variable to be used by the main thread of processing and
 * the interrupt processing
 */
volatile int InterruptProcessed = FALSE;

int main() {
	init_platform();
	int Status;
	unsigned int mode;
	unsigned int data;

	print("Hello World\n\r");

	GicConfig = XScuGic_LookupConfig(XPAR_INTC_HANDLER_TABLE);
	if (NULL == GicConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(&InterruptController, GicConfig,
			GicConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Perform a self-test to ensure that the hardware was built
	 * correctly
	 */
	Status = XScuGic_SelfTest(&InterruptController);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	print("self test passed\n\r");

	XScuGic_SetPriorityTriggerType(&InterruptController, XPAR_FABRIC_UART_TOP_0_IRQREQ_INTR, 0xA0, 0x3);

	/*
	 * Connect a device driver handler that will be called when an
	 * interrupt for the device occurs, the device driver handler performs
	 * the specific interrupt processing for the device
	 */
	Status = XScuGic_Connect(&InterruptController, XPAR_FABRIC_UART_TOP_0_IRQREQ_INTR,
			(Xil_ExceptionHandler) DeviceDriverHandler,
			(void *) &InterruptController);

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	print("connection passed\n\r");
	/*
	 * Enable the interrupt for the device and then cause (simulate) an
	 * interrupt so the handlers will be called
	 */
	XScuGic_Enable(&InterruptController, XPAR_FABRIC_UART_TOP_0_IRQREQ_INTR);

	print("enabled\n\r");


	print("interrupt enabled \n\r");
	/*
	 * Initialize the exception table and register the interrupt
	 * controller handler with the exception table
	 */
	Xil_ExceptionInit();

	/*
	 * Setup the Interrupt System
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler) XScuGic_InterruptHandler,
			&InterruptController);

	/*
	 * Enable interrupts in the ARM
	 */
	Xil_ExceptionEnable();
	///////////////////////////////////////////////////////////////////////
	
	unsigned int base_addr = 0x43c00000;

	while (1) {
		printf("**************\n\r");
		printf("Select Mode:\n");
		printf("1. TX Mode\n");
		printf("2. RX Mode\n");
		printf("3. RX Read\n");
		printf("4. Exit Program\n");
		printf("Enter your choice: ");
		scanf("%u", &mode);
		printf("mode:%d\n\r", mode);


		if (mode == 1) //Tx Mode
		{
			unsigned int rem = 1;
			while(rem == 1){
				printf("Enter data to transmit : \n\r");
				scanf("%x", &data);
				printf("data:%d\n\r", data);
				Xil_Out32(base_addr, data);
				printf("More data to transmit? : 1/0(Y/N)\n\r");
				scanf("%u", &rem);
			}
			Xil_Out32(base_addr + 0x3, 0x00);
			printf("TX DONE successfully\n");
		}

		else if (mode == 2) //Rx Mode
		{
			unsigned int received_data;
			{
					Xil_Out32(base_addr + 0x3, 0x01);
					printf("RX MODE successfully\n");
			}
		}
		else if (mode == 3) //RX Read
		{
			unsigned int received_data;
			{
				received_data = Xil_In32(base_addr + 0x01);
					printf("Received data: %08x\n", received_data);
					printf("RX READ successfully\n");
			}
		}
	}
	cleanup_platform();
	return 0;
}

void DeviceDriverHandler(void *CallbackRef) {
	int IntIDFull;
	/*
	 * Indicate the interrupt has been processed using a shared variable
	 */

	print("handler called!\n\r");
	InterruptProcessed = TRUE;

	IntIDFull = XScuGic_CPUReadReg(&InterruptController,
			XSCUGIC_INT_ACK_OFFSET);
	XScuGic_CPUWriteReg(&InterruptController, XSCUGIC_EOI_OFFSET, IntIDFull);
}
