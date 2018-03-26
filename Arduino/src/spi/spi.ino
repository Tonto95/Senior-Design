#include <SPI.h>

#define KNEE_ANGLE 3 //Chip or Slave select 
#define HIP_ANGLE 4 //Chip or Slave select
#define KNEE_TORQUE A1
#define HIP_TORQUE A2
#define T_OFFSET 1.85
#define T_SENSITIVITY (8*6/5.6) 
#define CONV_D2R M_PI/180

#define BETA 0.9
#define T 0.005


uint16_t ABSposition = 0;
uint16_t ABSposition_last = 0;
uint8_t temp[2];
float values[5];
float test = 20.0;

// State:
// 0: knee angle
// 1: hip angle
// 2: knee torque
// 3: hip torque
// 4: knee angular velocity
// 5: hip angular velocity
// 6: ankle positionx
// 7: ankle positiony
float state[8];
float stateavg[8];
float L[2];

float deg = 0.00;
float knee_deg = 0.00;
float hip_deg = 0.00;
float hip_torque = 0.00;
float knee_torque = 0.00;
int adc_output;
float voltage;
float torque;
float avg_hip = 0.00;
float avg_knee = 0.00;

void setup()
{
  // encoder set up
  pinMode(KNEE_ANGLE,OUTPUT);//Slave Select
  digitalWrite(KNEE_ANGLE,HIGH);
  pinMode(HIP_ANGLE,OUTPUT);//Slave Select
  digitalWrite(HIP_ANGLE,HIGH);
  SPI.begin();
  SPI.setBitOrder(MSBFIRST);
  SPI.setDataMode(SPI_MODE0);
  SPI.setClockDivider(SPI_CLOCK_DIV32); 

  //torque sensor set up
  pinMode(HIP_TORQUE, INPUT);
  digitalWrite(HIP_TORQUE, LOW);
  pinMode(KNEE_TORQUE, INPUT);
  digitalWrite(KNEE_TORQUE, LOW);

  // general set up
  Serial.begin(9600);
//  Serial.println("STARTING...");
//  Serial.println("SETTING ZERO...");
  values[0] = -10000;
  
//  uint8_t signal = SPI_T(0x70);    // set zero at set up
//  while (signal != 0x80) {
//    signal = SPI_T(0x00);
//  }
  Serial.flush();
  delay(2000);
  SPI.end();

  for (int i = 0; i < 6; i++) {
    state[i] = 0;
    stateavg[i] = 0;
  }

  L[0] = 0.7;
  L[1] = 0.5;
}
uint8_t SPI_T (uint8_t msg, int joint)    //Repetive SPI transmit sequence
{
   uint8_t msg_temp = 0;  //vairable to hold recieved data
   digitalWrite(joint,LOW);     //select spi device
   msg_temp = SPI.transfer(msg);    //send and recieve
   digitalWrite(joint,HIGH);    //deselect spi device
   return(msg_temp);      //return recieved byte
}

float get_angle(int joint) {
  uint8_t recieved = 0xA5;    //just a temp vairable
   ABSposition = 0;    //reset position vairable
   
   SPI.begin();    //start transmition
   digitalWrite(joint,LOW);
   
   SPI_T(0x10, joint);   //issue read command
   
   recieved = SPI_T(0x00, joint);    //issue NOP to check if encoder is ready to send
   
   while (recieved != 0x10)    //loop while encoder is not ready to send
   {
     recieved = SPI_T(0x00, joint); 
     //Serial.println(recieved, HEX); //cleck again if encoder is still workin     delay(2);    //wait a bit
   }
   
   temp[0] = SPI_T(0x00, joint);    //Recieve MSB
   temp[1] = SPI_T(0x00, joint);    // recieve LSB
   
   digitalWrite(joint,HIGH);  //just to make sure   
   SPI.end();    //end transmition
   
   temp[0] &=~ 0xF0;    //mask out the first 4 bits
    
   ABSposition = temp[0] << 8;    //shift MSB to correct ABSposition in ABSposition message
   ABSposition += temp[1];    // add LSB to ABSposition message to complete message
    
   if (ABSposition != ABSposition_last)    //if nothing has changed dont wast time sending position
   {
     ABSposition_last = ABSposition;    //set last position to current position
     deg = ABSposition;
     deg = deg * 0.08789;    // aprox 360/4096
     return deg;
   }   

   delay(10);
  
}

float get_torque(int joint, float avg) {
  adc_output = analogRead(joint);
  voltage = (5.0/1024)*adc_output;
  
  torque = (voltage-T_OFFSET)*T_SENSITIVITY;
  
  return torque;
}

void send_values(float* values, int len) {
  for (int i = 0; i < len; i++) {
    Serial.println(values[i]);
  }
}

void average(float* avg, float* curr, int len) {
  for(int i = 0; i < len i++) {
    avg[i] = BETA*avg[i]+(1-BETA)*curr[i]
  }
}

void loop()
{
       Serial.println("kwasia");
       values[1] = get_angle(KNEE_ANGLE);
       values[2] = get_angle(HIP_ANGLE);
       values[3] = get_torque(KNEE_TORQUE, avg_hip);
       values[4] = get_torque(HIP_TORQUE, avg_knee);

       
       for(int i = 0; i < 4; i++) {
        state[i] = values[i+1];
       }
       state[4] = (stateavg[0]-state[0])/T;
       state[5] = (stateavg[1]-state[1])/T;

       average(stateavg, state, 6);

       send_values(values, 5);
}