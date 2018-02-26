/*******************************************************************************
* Application: Blinky
* Filename:    main.c
* Author:      Cory Perkins
*******************************************************************************/
#include "main.h"

#define LED_PIN               GPIO_PIN_5
#define LED_GPIO_PORT         GPIOA
#define LED_GPIO_CLK_ENABLE() __HAL_RCC_GPIOA_CLK_ENABLE()
#define LED_FLASH_PERIOD      100

TaskHandle_t blinkTaskHandle;

void LED_Init();
void BlinkTask(void const *argument);

int main(void) {
  HAL_Init();
  LED_Init();

  osThreadDef(blinkTask, BlinkTask, osPriorityNormal, 0, 128);
  blinkTaskHandle = osThreadCreate(osThread(blinkTask), NULL);

  /* Start scheduler */
  osKernelStart();

  while (1);
}

void LED_Init() {
  LED_GPIO_CLK_ENABLE();
  GPIO_InitTypeDef GPIO_InitStruct;
  GPIO_InitStruct.Pin = LED_PIN;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  GPIO_InitStruct.Speed = GPIO_SPEED_HIGH;
  HAL_GPIO_Init(LED_GPIO_PORT, &GPIO_InitStruct);
}

void BlinkTask(void const *argument) {
  while (1) {
    HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
    osDelay(LED_FLASH_PERIOD);
  }
}
