<patch-1.0 appVersion="1.0.12">
   <patchobj type="patch/object" uuid="251c57d1-6833-4666-a469-fb7c2b44e6c9" name="bankindex_1" x="182" y="154">
      <params/>
      <attribs/>
      <object id="patch/object" uuid="251c57d1-6833-4666-a469-fb7c2b44e6c9">
         <author>JS</author>
         <license>BSD</license>
         <inlets>
            <int32 name="x"/>
            <int32 name="y"/>
            <int32 name="character"/>
            <bool32 name="trigger"/>
         </inlets>
         <outlets/>
         <displays/>
         <params/>
         <attribs/>
         <includes/>
         <code.declaration><![CDATA[int count = 0;
int initialize = 0;
int lastValue[128];
int queueHead = 0;
int queueTail = 0;
int inQueue = 0;
uint8_t midiQueue[512]; // we need quite a lot because setting all APC key25 values are 53 values
const int cursorKeyIndex = 40;
const int sceneKeyIndex = 48;
const int cursorKeysNote = 64;
const int sceneKeysNote = 82;


void setButtonKey(uint8_t index, uint8_t value)
{
	AddMidiMessage(MIDI_NOTE_ON, index, value); 
}

void resetAll(uint8_t value)
{
	for (auto i=0; i < 40; ++i)
	{
		setButtonKey(i, value);
	}
	for (auto i=0; i < 8; ++i)
	{
		setButtonKey(cursorKeysNote+i, value);
	}
	for (auto i=0; i < 6; ++i)
	{
		setButtonKey(sceneKeysNote+i, value);
	}
}

void feedQueue(uint8_t value)
{
	inQueue++;
	midiQueue[queueHead++] = value;
	if (queueHead >= sizeof(midiQueue)/sizeof(midiQueue[0]))
		queueHead = 0;	
}

int countFood() 
{
	return inQueue;
}

uint8_t eatQueue()
{
	auto value = midiQueue[queueTail++];
	if (queueTail >= sizeof(midiQueue)/sizeof(midiQueue[0]))
		queueTail = 0;	
	inQueue--;
	return value;
}

void AddMidiMessage(uint8_t status, uint8_t data1, uint8_t data2)
{
	feedQueue(status);
	feedQueue(data1);
	feedQueue(data2);
}


const int8_t smallNumberFont[20] = {31, 31, 0,  31, 23, 29, 21, 31, 28, 15,
                                    29, 23, 31, 23, 16, 31, 21, 21, 29, 31};

const int8_t digitsAndLetter[41 * 3] = {
    31, 17, 31, 0,  31, 0,  23, 21, 29, 21, 21, 31, 28, 4,  15, 29, 21, 23,
    31, 21, 23, 16, 16, 31, 31, 21, 31, 28, 20, 31, 31, 20, 31, 31, 21, 27,
    31, 17, 17, 31, 17, 14, 31, 21, 21, 31, 20, 16, 31, 17, 23, 31, 4,  31,
    0,  31, 0,  3,  1,  31, 31, 4,  27, 31, 1,  1,  31, 8,  31, 15, 4,  30,
    31, 17, 31, 31, 20, 28, 30, 18, 31, 31, 20, 11, 29, 21, 23, 16, 31, 16,
    31, 1,  31, 30, 1,  30, 31, 2,  31, 27, 4,  27, 24, 7,  24, 19, 21, 25, // Z
    0,  29, 0,                                                              // !
    4,  31, 4,                                                              // +
    4,  4,  4,                                                              // -
    31, 5,  6,                                                              // b
    31, 10, 31,                                                             //#
};

int8_t currentMatrix[5][8];
int8_t newMatrix[5][8];

void renderNewMatrix() {
  for (int x = 0; x < 8; ++x) {
    for (int y = 0; y < 5; ++y) {
      if (newMatrix[y][x] != currentMatrix[y][x]) {
      	//LogTextMessage("pos %d, value %d", x + y * 8, newMatrix[y][x]);
      	AddMidiMessage(0x90, x + y * 8, newMatrix[y][x]); 
          currentMatrix[y][x] = newMatrix[y][x];
      }
    }
  }
}

void setMatrixColumn(int x, int value, int8_t color) {
  if (x >= 8)
    return;
  for (int y = 0; y < 5; ++y) {
    if ((value & 0x01) == 1) {
      newMatrix[y][x] = color;
    }
    else
      newMatrix[y][x] = 0;
    value >>= 1;
  }
}

void setText(int8_t x, char value, int8_t color=1) {
  int index = -1;
  if ((value >= '0') && (value <= '9'))
    index = (value - '0') * 3;
  if ((value >= 'A') && (value <= 'Z'))
    index = (value - 'A' + 10) * 3;
  if ((value >= 'a') && (value <= 'z'))
    index = (value - 'a' + 10) * 3;
  if (index >= 0) {
    setMatrixColumn(x++, digitsAndLetter[index++], color);
    setMatrixColumn(x++, digitsAndLetter[index++], color);
    setMatrixColumn(x++, digitsAndLetter[index++], color);
    setMatrixColumn(x, 0, color);
  }
}

void setSmallNumber(int8_t x, int value, int8_t color=1) {
  setMatrixColumn(x++, smallNumberFont[value * 2], color);
  setMatrixColumn(x++, smallNumberFont[value * 2 + 1], color);
  setMatrixColumn(x, 0, color);
}]]></code.declaration>
         <code.init><![CDATA[setText(0,'5',1);
setText(4,'J',1);]]></code.init>
         <code.krate><![CDATA[auto foodCnt = countFood();

if (foodCnt)
{
	auto len = MidiGetOutputBufferAvailable(MIDI_DEVICE_USB_HOST);
	//LogTextMessage("food: %d, midilen %d", countFood(), len);
	if (len >= 3)
	{
		auto status = eatQueue();
		uint8_t value2, value3;
		switch(status & 0xF0)
		{
			case 0x80:
			case 0x90:
			case 0xA0:
			case 0xB0:
			case 0xE0:
				value2 = eatQueue();
				value3 = eatQueue();
				//LogTextMessage("value: %02x %02x %02x", status, value2, value3);
				MidiSend3(MIDI_DEVICE_USB_HOST, 1, status, value2, value3); 
				break;
			case 0xC0:
			case 0xD0:
				value2 = eatQueue();
				//LogTextMessage("value: %02x %02x", status, value2);
				MidiSend2(MIDI_DEVICE_USB_HOST, 1, status, value2); 
				break;
			
		}
	}
}


static int updateTrigger = 0;

static int countUp=0;
static int beat = 30000;
beat--;
if (beat <=0)
{
	countUp++;
	if (countUp==100)countUp = 0;
	setText(0,'0'+countUp/10,1);
	setText(4,'0'+countUp%10,1);
	renderNewMatrix();
	beat=800;
}

if (--updateTrigger <= 0)
{
	renderNewMatrix();
	updateTrigger = 3;
}]]></code.krate>
         <code.midihandler><![CDATA[LogTextMessage("value: %02x %02x %02x", status, data1, data2);

if (status == MIDI_NOTE_ON)
{
	lastValue[data1]++;
	auto maxValue = data1>=64 ? 3 : 7;
	if (lastValue[data1] >= maxValue)
		lastValue[data1] = 0;
	MidiSend3(MIDI_DEVICE_USB_HOST, 1, MIDI_NOTE_ON, data1, lastValue[data1]); 
}
if (status == MIDI_CONTROL_CHANGE)
{
	if ((data1>=48 && data1<=55))
	{
		MidiSend3(MIDI_DEVICE_USB_HOST, 1, MIDI_NOTE_ON, data1-48, data2*7/128); 
	}
}]]></code.midihandler>
      </object>
   </patchobj>
   <nets/>
   <settings>
      <subpatchmode>no</subpatchmode>
   </settings>
   <notes><![CDATA[]]></notes>
   <windowPos>
      <x>405</x>
      <y>116</y>
      <width>873</width>
      <height>757</height>
   </windowPos>
</patch-1.0>