/*
** EPITECH PROJECT, 2019
** UltrasonicReader
** File description:
** ultrasonicio_raspi
*/

#ifndef _ULTRASONICIO_RASPI_H_
#define _ULTRASONICIO_RASPI_H_

#include "rtwtypes.h"

// typedef enum UNIT_SELECTION
// {
//     US_INCHES,
//     US_CM,
//     US_M
// };

void ultrasonicIOSetup(uint8_T echo, uint8_T trigger);
void writeTriggerPin(uint8_T pin);
real_T readUltrasonicDistance(void); //, UNIT_SELECTION unit);


#endif /* !_ULTRASONICIO_RASPI_H_ */
