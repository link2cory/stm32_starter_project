/*******************************************************************************
* Application: Blinky
* Filename:    main.c
* Author:      Cory Perkins
*******************************************************************************/
#include "main.h"

#define LED_PIN               GPIO_PIN_5
#define LED_GPIO_PORT         GPIOA
#define LED_GPIO_CLK_ENABLE() __HAL_RCC_GPIOA_CLK_ENABLE()
#define LED_FLASH_PERIOD      1000

void LED_Init();

int main(void) {
  HAL_Init();
  LED_Init();

  while (1)
  {
    HAL_GPIO_TogglePin(LED_GPIO_PORT, LED_PIN);
    HAL_Delay(1000);
  }
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