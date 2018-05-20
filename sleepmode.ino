// Author: Xuan Ha Nghiem
// VVI pacemaker
// Fucntion: senses/detect heart beats
// fires pulse in case of low heart rate
// Addtional feature: Sleep mode
// This program checks for heart rate patterns that are low within the
// the normal heart rate and sleep rate. The rates to fire a pulse will lower
// or increase in case this is true. The assumption here is that the heart dysfunctionalities
// are random and that its normal/sleep rates are not.
// average hrt rate of frog 40-50bpm 1.2-1.5 sec
// baseline 30 BPMM - with caffeine to 27bpm
// 2 sec - with caffeine 2.2222sec

int set_time = 0;
int bed_time = 0;
int wake_time = 0;

int digital_in = 2;    // signal input
int digital_out = 13;  // pulse output

int digital_out1 = 12;  // interval increase
int digital_out2 = 11;  // interval decrease

volatile int  digitalState = 0;  // stores acquired data
volatile unsigned long   interval = 1.2 * 1000000;  // pulse timing
volatile unsigned long prev_t = 0;   // prev time
volatile unsigned long curr_t = 0;   // current time
volatile unsigned long pulse_time = -1;  // timing of pulse

volatile int prev_state = 0;   // previous data acquired

int sum_hrtbeat = 0;  //  sum up condition of heart beat
//  1 for condition near sleep rate
//  0 for normal rate
int count_hrtbeat = -1;  // count number of heart beats
int count_limit = 20;

float num = 90.0;  // divides number of steps
volatile unsigned long  hrtbeat_sleep = 1.7 * 1000000;  // sleep rate
volatile unsigned long  hrtbeat_normal = 1.2 * 1000000;  // normal heart rate
volatile unsigned long  change_baseline = (hrtbeat_sleep - hrtbeat_normal) / (num);
// step down of heart rate to the sleep rate

// conditions for initial baseline heart rate of frog
boolean check_condition = true;
int count_condition = 0;
float av_frog_hrt = 0;

float avg_frog = 0;
float count_frog = 0;

// 1 for hrt rate decrease
// 2 for hrt rate increase
int check_baseline[20];
int count_baseline = 0;
int count_baseline_limit = 20;
boolean check_baseline_condition = false;

float check_adapt_interval = 0.0;
volatile unsigned long hrt_interval[] = {hrtbeat_normal, hrtbeat_normal};

// RUN SETUP() FUNCTION
void setup()
{
  // initialization of pin
  Serial.begin(9600);
  pinMode(digital_in, INPUT);
  digitalWrite(digital_in, LOW);
  pinMode(digital_out, OUTPUT);
  digitalWrite(digital_out, LOW);
  pinMode(digital_out1, OUTPUT);
  digitalWrite(digital_out1, LOW);
  pinMode(digital_out2, OUTPUT);
  digitalWrite(digital_out2, LOW);
}


void loop()
{
  //////////////////////////////////////////////////////////////
  //   finds baseline heart rate of frog
  //    while (check_condition) {
  //
  //      // acquire data
  //      prev_state = digitalState;
  //      digitalState = digitalRead(digital_in);
  //
  //      // detect beat
  //      if (digitalState > prev_state) {
  //        prev_t = curr_t;
  //        curr_t = micros();
  //        if (prev_t != 0) {
  //
  //          float hr = 60 / (((float)(curr_t - prev_t) / 1000000));
  //          Serial.print("HR: ");
  //          Serial.println(hr);
  //
  //          count_condition = count_condition + 1;
  //          Serial.print("Count: ");
  //          Serial.println(count_condition);
  //          av_frog_hrt = av_frog_hrt + (curr_t - prev_t);
  //        }
  //      }
  //      if (count_condition > 10) {
  //        av_frog_hrt = av_frog_hrt / count_condition;
  //        hrtbeat_normal = av_frog_hrt;
  //        hrtbeat_sleep = av_frog_hrt + .25 * 1000000;
  //        change_baseline = .25 * 1000000 / num;
  //        interval = hrtbeat_normal + .25 * 1000000 * .5;
  //        // check_condition = false;
  //        Serial.print("Av HR: ");
  //        Serial.println(60 / (((float)(av_frog_hrt) / 1000000)));
  //        Serial.print("Sleep Rate: ");
  //        Serial.println(60 / (((float)(hrtbeat_sleep) / 1000000)));
  //        Serial.print("Firing Rate: ");
  //        Serial.println(60 / (((float)(interval) / 1000000)));
  //       delay(1000);
  //
  //        avg_frog = avg_frog + av_frog_hrt;
  //        count_frog = count_frog + 1;
  //        Serial.print("Av Frog HR: ");
  //        Serial.println(60 / (((float)((float)avg_frog/count_frog) / 1000000)));
  //        Serial.print("Av Frog HR Interval: ");
  //        Serial.println((float)avg_frog/count_frog);
  //
  //        if (count_frog > 5){
  //        check_condition = false;
  //        av_frog_hrt = (float)avg_frog/count_frog;
  //        hrtbeat_normal = av_frog_hrt;
  //        hrtbeat_sleep = av_frog_hrt + .25 * 1000000;
  //        change_baseline = .25 * 1000000 / num;
  //        interval = hrtbeat_normal + .25 * 1000000 * .5;
  //        Serial.print("Av HR Interval: ");
  //        Serial.println((av_frog_hrt));
  //        Serial.print("Sleep Rate Interval: ");
  //        Serial.println(hrtbeat_sleep);
  //        Serial.print("Firing Rate Interval: ");
  //        Serial.println(interval);
  //        delay(1000);
  //        }
  //
  //        count_condition = 0;
  //        av_frog_hrt = 0;
  //              prev_t = 0;
  //        curr_t = 0;
  //
  //      }
  //
  //    }
  //
  ///////////////////////////////////////////////////////////

  // acquire data
  prev_state = digitalState;  // prev recording
  digitalState = digitalRead(digital_in);  // current acquisition

  // detect beat
  if (digitalState > prev_state) {
    prev_t = curr_t;
    curr_t = micros();

    // Calculate hr
    if (prev_t != 0) {
      float hr = 60 / (((float)(curr_t - prev_t) / 1000000));
      Serial.print("HR: ");
      Serial.println(hr);
      Serial.println(curr_t - prev_t);
    }

    // filters out case when pulse was fired and too close to peak
    if (micros() - pulse_time > hrtbeat_normal * .5) {
      count_hrtbeat = count_hrtbeat + 1; // sum condition where
      // heart rate is near sleep rate
      Serial.println(count_hrtbeat);
      if (count_hrtbeat > 0) {
        if (curr_t - prev_t > hrtbeat_normal + .6 * (hrtbeat_sleep - hrtbeat_normal) & curr_t - prev_t < hrtbeat_sleep + .6 * (hrtbeat_sleep - hrtbeat_normal)) {
          sum_hrtbeat = sum_hrtbeat + 1;
          Serial.println("sum");
          Serial.println(sum_hrtbeat);
        }

        if (count_hrtbeat > count_limit) {
          // heart rate decreases

          count_baseline = count_baseline + 1;
          check_baseline[count_baseline] = 0;
          check_baseline_condition = true;

          if ((float)sum_hrtbeat / count_hrtbeat > .5) {
            interval = interval + change_baseline;
            // count_baseline = count_baseline + 1;
            check_baseline[count_baseline] = 1;
            hrt_interval[1] = curr_t - prev_t;
            hrt_interval[1] = hrt_interval[1] / 2;
            Serial.println("HR Decrease");
            digitalWrite(digital_out1, HIGH);
            digitalWrite(digital_out2, LOW);
            Serial.print("Interval: ");
            Serial.println(interval);
          }

          // heart rate increases
          if ((float)sum_hrtbeat / count_hrtbeat < .5 ) {
            interval = interval - change_baseline;
            // count_baseline = count_baseline + 1;
            check_baseline[count_baseline] = 2;
            hrt_interval[2] = curr_t - prev_t;
            hrt_interval[2] = hrt_interval[2] / 2;
            Serial.println("HR Increase");
            digitalWrite(digital_out2, HIGH);
            digitalWrite(digital_out1, LOW);
            Serial.print("Interval: ");
            Serial.println(interval);
          }

          // sets interval increments back to baseline limit of either
          // normal heart rate or sleep rate
          if (interval < hrtbeat_normal) {
            interval = interval + change_baseline;
            digitalWrite(digital_out2, LOW);
            Serial.print("Interval1: ");
            Serial.println(interval);
          }
          if (interval > hrtbeat_sleep)  {
            interval = interval - change_baseline;
            digitalWrite(digital_out1, LOW);
            Serial.print("Interval1: ");
            Serial.println(interval);
          }
          sum_hrtbeat = 0;
          count_hrtbeat = 0;
        }
      }
    }
  }


  // fire pulse  in case low heart rate
  if (micros() - curr_t > interval) {
    digitalWrite(digital_out, HIGH);
    delay(41);
    digitalWrite(digital_out, LOW);
    Serial.println("Pulse generated");
    pulse_time = micros();

    // Calculate hr
    if (prev_t != 0) {
      float hr = 60 / (((float)(micros() - curr_t) / 1000000));
      Serial.print("HR: ");
      Serial.println(hr);
      Serial.println(micros() - curr_t);
    }

    if (curr_t - prev_t < interval) {
      count_hrtbeat = count_hrtbeat + 1;
      Serial.println(count_hrtbeat);
      if (count_hrtbeat > 0) {
        sum_hrtbeat = sum_hrtbeat + 1;
        Serial.println("sum");
        Serial.println(sum_hrtbeat);
        if (count_hrtbeat > count_limit) {
          if ((float)sum_hrtbeat / count_hrtbeat > .5) {
            interval = interval + change_baseline;
            Serial.println("HR Decrease");
            digitalWrite(digital_out1, HIGH);
            digitalWrite(digital_out2, LOW);
            Serial.print("Interval: ");
            Serial.println(interval);
          }
          if ((float)sum_hrtbeat / count_hrtbeat < .5 ) {
            interval = interval - change_baseline;
            Serial.println("HR Increase");
            digitalWrite(digital_out2, HIGH);
            digitalWrite(digital_out1, LOW);
            Serial.print("Interval: ");
            Serial.println(interval);
          }

          count_baseline = count_baseline + 1;
          check_baseline[count_baseline] = 0;
          check_baseline_condition = true;

          if (interval < hrtbeat_normal) {
            digitalWrite(digital_out2, LOW);
            interval = interval + change_baseline;
            // count_baseline = count_baseline + 1;
            check_baseline[count_baseline] = 1;
            hrt_interval[1] = hrt_interval[1] + micros() - prev_t;
            hrt_interval[1] = hrt_interval[1] / 2;
            Serial.print("Interval1: ");
            Serial.println(interval);
          }
          if (interval > hrtbeat_sleep)  {
            digitalWrite(digital_out1, LOW);
            interval = interval - change_baseline;
            // count_baseline = count_baseline + 1;
            check_baseline[count_baseline] = 2;
            hrt_interval[2] = hrt_interval[2] + micros() - prev_t;
            hrt_interval[2] = hrt_interval[2] / 2;
            Serial.print("Interval1: ");
            Serial.println(interval);
          }
          sum_hrtbeat = 0;
          count_hrtbeat = 0;
        }
      }
    }
    prev_t = curr_t;
    curr_t = micros();
  }


  if (count_baseline > 0 && count_baseline <= count_baseline_limit && check_baseline_condition == true) {
    if ((check_baseline[count_baseline] == 2 & check_baseline[count_baseline - 1] == 1) || (check_baseline[count_baseline] == 1 & check_baseline[count_baseline - 1] == 2)) {
      check_adapt_interval = check_adapt_interval + 1;
    }
    check_baseline_condition == false;
  }


  if (count_baseline >= count_baseline_limit) {
    check_adapt_interval = check_adapt_interval / 10.0;
    if (check_adapt_interval > .7) {
      interval = (hrt_interval[1] + hrt_interval[2]) / 2;
    }
    count_baseline = 0;
    check_adapt_interval = 0;
  }


}

