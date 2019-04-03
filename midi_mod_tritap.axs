<patch-1.0 appVersion="1.0.12">
   <obj type="patch/inlet a" uuid="b577fe41e0a6bc7b5502ce33cb8a3129e2e28ee5" name="inlet_1" x="126" y="14">
      <params/>
      <attribs/>
   </obj>
   <obj type="trisfreq" uuid="9854c50a-4a8f-49fc-ad20-ca60a0eaf3a9" name="trisfreq_1" x="210" y="14">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/outlet a" uuid="abd8c5fd3b0524a6630f65cad6dc27f6c58e2a3e" name="outlet_1" x="350" y="14">
      <params/>
      <attribs/>
   </obj>
   <patchobj type="patch/object" uuid="8987539f-fb0a-4bc3-bf8a-bbd8478fe3ec" name="button_pot_1" x="14" y="28">
      <params/>
      <attribs>
         <combo attributeName="channel" selection="0"/>
      </attribs>
      <object id="patch/object" uuid="8987539f-fb0a-4bc3-bf8a-bbd8478fe3ec">
         <sDescription>enable serial2( PA2/PA3 = SD2, baudrate: 115200) as extra midi i/o to use with euxoloti. Pot, Button values are transmitted by midi and finally routed to object outlets.</sDescription>
         <author>Paul</author>
         <license>BSD</license>
         <inlets/>
         <outlets>
            <frac32 name="height"/>
            <frac32 name="pot1"/>
            <frac32 name="pot2"/>
            <frac32 name="pot3"/>
            <frac32 name="pot4"/>
            <frac32 name="pot5"/>
            <frac32 name="pot6"/>
         </outlets>
         <displays>
            <int32.label name="d1"/>
         </displays>
         <params/>
         <attribs>
            <combo name="channel">
               <MenuEntries/>
               <CEntries>
                  <string>0</string>
                  <string>1</string>
                  <string>2</string>
                  <string>3</string>
                  <string>4</string>
                  <string>5</string>
                  <string>6</string>
                  <string>7</string>
                  <string>8</string>
                  <string>9</string>
                  <string>10</string>
                  <string>11</string>
                  <string>12</string>
                  <string>13</string>
                  <string>14</string>
                  <string>15</string>
               </CEntries>
            </combo>
         </attribs>
         <includes/>
         <code.declaration><![CDATA[Thread* Thd;

int32_t pots[8] ={0,0,0,0, 0,0,0,0};
int32_t midiHeight = 0;
uint8_t midiBytes[3];
uint8_t midiCurData;
uint8_t midiNumData;

uint8_t StatusToMsgLength(uint8_t t)
{
    switch (t)
    {
        case 0x0:
        case 0x1:
        case 0x2:
        case 0x3:
        case 0x4:
        case 0x5:
        case 0x6:
        case 0x7: return 0;
        case 0x8:
        case 0x9:
        case 0xa:
        case 0xb: return 3;
        case 0xc:
        case 0xd: return 2;
        case 0xe: return 3;
        default: return -1;
    }
}

void MidiInByteHandler(uint8_t data)
{
    int8_t len;
    if (data & 0x80)
    {
        len = StatusToMsgLength(data >> 4);
        midiBytes[0] = data;
        midiNumData  = len - 1;
        midiCurData  = 0;
    }
    else
    {
        if (midiCurData == 0)
        {
            midiBytes[1] = data;
            midiCurData++;
        }
        else if (midiCurData == 1)
        {
            midiBytes[2] = data;
            if (midiNumData == 2)
            {
                if (midiBytes[0] == (0xB0 | attr_channel))
                {
                    if ((midiBytes[1] >= 0) && (midiBytes[1] <= sizeof(pots) / sizeof(pots[0])))
                    {
                        LogTextMessage("%02x, %02x, %02x", midiBytes[0], midiBytes[1], midiBytes[2]);
                        pots[midiBytes[1]] = midiBytes[2]<<20;
                    }
                }

                else if (midiBytes[0] == (0x90 | attr_channel))
                {
                    midiHeight = midiBytes[1]<<20;
                }
                midiCurData = 0;
            }
        }
    }
}

msg_t ThreadX2()
{
#if CH_USE_REGISTRY
is this used?
    chRegSetThreadName("euxo button pot"); // define thread name
#endif

    midiNumData = 0;
    midiCurData = 0;

    sdPut(&SD2, 0xFF);

    while (!chThdShouldTerminate())
    {
        while (!sdGetWouldBlock(&SD2))
        {
            uint8_t ch = sdGet(&SD2);
            LogTextMessage("v=%02x", (int) ch);
            MidiInByteHandler(ch);
        }
        chThdSleepMilliseconds(1);
    }
    chThdExit((msg_t) 0);
}

static msg_t EuxoButPot(void* arg)
{
    ((attr_parent*) arg)->ThreadX2();
}
WORKING_AREA(waEuxoButPot, 256);]]></code.declaration>
         <code.init><![CDATA[palSetPadMode(GPIOA, 3, PAL_MODE_ALTERNATE(7)|PAL_MODE_INPUT);// RX
palSetPadMode(GPIOA, 2, PAL_MODE_ALTERNATE(7));// TX

static const SerialConfig sd2Cfg = {115200, 0, 0, 0}; // set to midi baud rate but works also with higher baud rates.
sdStart(&SD2, &sd2Cfg);

Thd = chThdCreateStatic(waEuxoButPot, sizeof(waEuxoButPot),NORMALPRIO, EuxoButPot, (void *)this);]]></code.init>
         <code.dispose><![CDATA[chThdTerminate(Thd);
chThdWait(Thd);
sdStop(&SD2);]]></code.dispose>
         <code.krate><![CDATA[outlet_pot1 = this->pot[0];
outlet_pot2 = this->pot[1];
outlet_pot3 = this->pot[2];
outlet_pot4 = this->pot[3];
outlet_pot5 = this->pot[4];
outlet_pot6 = this->pot[5];


outlet_height = this->height;
disp_d1 = attr_channel;]]></code.krate>
      </object>
   </patchobj>
   <nets>
      <net>
         <source obj="inlet_1" outlet="inlet"/>
         <dest obj="trisfreq_1" inlet="inlet_1"/>
      </net>
      <net>
         <source obj="trisfreq_1" outlet="outlet_1"/>
         <dest obj="outlet_1" inlet="outlet"/>
      </net>
      <net>
         <source obj="button_pot_1" outlet="height"/>
         <dest obj="trisfreq_1" inlet="pitch"/>
      </net>
      <net>
         <source obj="button_pot_1" outlet="pot1"/>
         <dest obj="trisfreq_1" inlet="comb_feedback"/>
      </net>
      <net>
         <source obj="button_pot_1" outlet="pot2"/>
         <dest obj="trisfreq_1" inlet="comb_gain"/>
      </net>
      <net>
         <source obj="button_pot_1" outlet="pot3"/>
         <dest obj="trisfreq_1" inlet="ring_gain"/>
      </net>
      <net>
         <source obj="button_pot_1" outlet="pot4"/>
         <dest obj="trisfreq_1" inlet="inlet_6"/>
      </net>
      <net>
         <source obj="button_pot_1" outlet="pot5"/>
         <dest obj="trisfreq_1" inlet="inlet_7"/>
      </net>
   </nets>
   <settings>
      <subpatchmode>no</subpatchmode>
   </settings>
   <notes><![CDATA[]]></notes>
   <windowPos>
      <x>755</x>
      <y>57</y>
      <width>615</width>
      <height>555</height>
   </windowPos>
</patch-1.0>