#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <sys/time.h>
#include <time.h>
#include "ultrasonicio_raspi.h"

#define MSEC_TO_USEC            1000
#define MAX_ULTRASONIC_TIME_MS  (60 * MSEC_TO_USEC)
#define SETTLE_TIME_MS          (10 * MSEC_TO_USEC)
#define PULSE_TIME_US           10

static volatile long time_difference;
static uint8_T echoPin = 0;
static uint8_T triggerPin = 0;
boolean_T initialized = false;

long getMicrotimeDiff(long end, long start)
{
    if (end < start)
    {
        end += 1e6;
    }
    return end - start;
}

long getMicrotime(){
	struct timeval currentTime;
	gettimeofday(&currentTime, NULL);
	return currentTime.tv_usec;
}

bool checkEcho(const uint8_T pin, const uint8_T val, long *timestamp)
{
    long elapsed_time = getMicrotime();
    while(digitalRead(pin) != val)
    {
        if (getMicrotimeDiff(getMicrotime(), elapsed_time) > MAX_ULTRASONIC_TIME_MS)
        {
            return false;
        }
    }
    *timestamp = getMicrotime();
    return true;
}

PI_THREAD (myThread)
{
    long start, end;

    (void)piHiPri (10) ;	// Set this thread to be high priority
     
    for (;;)
    {
        // Handle trigger signal
        writeTriggerPin(triggerPin);

        // wait for echo to go high
        if (checkEcho(echoPin, HIGH, &start))
        {
            // wait for echo to go low
            if (checkEcho(echoPin, LOW, &end))
            {
                // find difference
                time_difference = getMicrotimeDiff(end, start);
            }
        }
        delayMicroseconds(SETTLE_TIME_MS);
    }
}

void ultrasonicIOSetup(uint8_T trigger, uint8_T echo)
{
    echoPin = echo;
    triggerPin = trigger;
    // Perform one-time wiringPi initialization
    if (!initialized)
    {
        wiringPiSetupGpio();
        initialized = 1;
    }
    
    pinMode(triggerPin, OUTPUT);
    pinMode(echoPin, INPUT);

    if (piThreadCreate (myThread) != 0)
    {
        return;
    }
}

void writeTriggerPin(uint8_T pin)
{
    // delayMicroseconds(2);
    digitalWrite(pin, HIGH);
    delayMicroseconds(PULSE_TIME_US);
    digitalWrite(pin, LOW);
}

real_T readUltrasonicDistance(void) //, UNIT_SELECTION unit)
{ 
    real_T time_delta;
    piLock (0) ;
    time_delta = time_difference; 
    piUnlock (0) ;
    return (real_T)time_delta / 148.0f; // measure in inches
}


        
	

       
	

