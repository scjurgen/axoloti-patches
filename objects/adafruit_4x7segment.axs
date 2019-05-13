<patch-1.0 appVersion="1.0.12">
   <obj type="patch/inlet i" uuid="f11927f00c59219df0c50f73056aa19f125540b7" name="intvalue" x="14" y="14">
      <params/>
      <attribs/>
   </obj>
   <patchobj type="patch/object" uuid="492db39d-c840-4232-b4ac-13f31a6099b7" name="mpr121_int_1" x="168" y="14">
      <params/>
      <attribs/>
      <object id="patch/object" uuid="492db39d-c840-4232-b4ac-13f31a6099b7">
         <author>Jason Harris</author>
         <license>BSD</license>
         <inlets>
            <int32 name="i1"/>
            <bool32 name="dbldot"/>
            <int32 name="prefixCharacter"/>
         </inlets>
         <outlets/>
         <displays/>
         <params/>
         <attribs/>
         <includes>
            <include>os/various/chprintf.h</include>
         </includes>
         <depends>
            <depend>I2CD1</depend>
         </depends>
         <code.declaration><![CDATA[#if CH_KERNEL_MAJOR == 2
#define THD_WORKING_AREA_SIZE THD_WA_SIZE
#define MSG_OK RDY_OK
#define THD_FUNCTION(tname, arg) msg_t tname(void *arg)
#endif

#define ENABLE_OSCILL 0x21
#define BRIGHTNESS 0xE0
#define DISPLAY_ON 0x81

#define ADASEG_I2C_TIMEOUT 30	// chibios ticks


struct ada7seg_state {
	stkalign_t thd_wa[THD_WORKING_AREA_SIZE(512) / sizeof(stkalign_t)];	
	Thread *thd;		
	I2CDriver *dev;
	i2caddr_t adr;	
	uint8_t *tx;
	bool hasNewValue;
	int32_t value;
	bool hasPrefix;
	int prefix;

	uint16_t currentData[5];
	uint16_t displayValue[10];

	void setDirectValue(int pos, int val)
	{
		currentData[pos] = val;
		hasNewValue = true;
	}
	
	void setNewValues(char *outb, int i)
	{
		currentData[2] = 0;
		
		while (*outb)
		{
			int idx = i>1?i+1:i;
			switch(*outb)
			{
				case ' ': currentData[idx] = 0; break;
				case '-': currentData[idx] = 64; break;
				case 'A': currentData[idx] = 119; break;
				case 'b': currentData[idx] = 124; break;
				case 'C': currentData[idx] = 57; break;
				case 'd': currentData[idx] = 94; break;
				case 'E': currentData[idx] = 121; break;
				case 'F': currentData[idx] = 113; break;
				case 'G': currentData[idx] = 61; break;
				case 'H': currentData[idx] = 118; break;
				case 'I': currentData[idx] = 6; break;
				case 'J': currentData[idx] = 30; break;
				case 'L': currentData[idx] = 56; break;
				case 'P': currentData[idx] = 115; break;
				case 'S': currentData[idx] = 109; break;
				case 'U': currentData[idx] = 62; break;
				case 'y': currentData[idx] = 110; break;
				default:
					if ((*outb >= '0') && (*outb <= '9'))
					{	
						currentData[idx] = displayValue[*outb-'0'];
					}
					break;
			}
			//LogTextMessage("%d %d", idx, currentData[idx]);
			i++;
			outb++;
		}
		hasNewValue = true;	
	}

	void setDoubleDot(bool isOn)
	{
		if (isOn)
			currentData[2] = 2;
		else
			currentData[2] = 0;
		hasNewValue = true;	
	}
};

static void *ada7seg_malloc(size_t size) {
	static uint8_t pool[32] __attribute__ ((section(".sram2.ada7seg")));
	static uint32_t free = 0;
	void *ptr = NULL;
	size = (size + 3) & ~3;
	chSysLock();
	if ((free + size) <= sizeof(pool)) {
		ptr = &pool[free];
		free += size;
	}
	chSysUnlock();
	return ptr;
}

// write an 8 bit value 
static int ada7seg_wr8(struct ada7seg_state *s, uint8_t reg) {
	s->tx[0] = reg;
	i2cAcquireBus(s->dev);
	msg_t rc = i2cMasterTransmitTimeout(s->dev, s->adr, s->tx, 1, NULL, 0, ADASEG_I2C_TIMEOUT);
	i2cReleaseBus(s->dev);
	return (rc == MSG_OK) ? 0 : -1;
}

// write an 8 bit value to a register
static int ada7seg_wr8(struct ada7seg_state *s, uint8_t reg, uint8_t val) {
	s->tx[0] = reg;
	s->tx[1] = val;
	i2cAcquireBus(s->dev);
	msg_t rc = i2cMasterTransmitTimeout(s->dev, s->adr, s->tx, 2, NULL, 0, ADASEG_I2C_TIMEOUT);
	i2cReleaseBus(s->dev);
	return (rc == MSG_OK) ? 0 : -1;
}

// write an 8 bit value to a register
static int ada7seg_wr8(struct ada7seg_state *s, uint8_t reg, uint8_t *val, int size) {
	s->tx[0] = reg;
	for (int i=0; i < size; ++i)
	{
		s->tx[1+i] = val[i];
	}
	i2cAcquireBus(s->dev);
	msg_t rc = i2cMasterTransmitTimeout(s->dev, s->adr, s->tx, size+1, NULL, 0, ADASEG_I2C_TIMEOUT);
	i2cReleaseBus(s->dev);
	return (rc == MSG_OK) ? 0 : -1;
}


static void ada7seg_info(struct ada7seg_state *s, const char *msg) {
	LogTextMessage("ada7seg(0x%x) %s", s->adr, msg);
}

static void ada7seg_error(struct ada7seg_state *s, const char *msg) {
	ada7seg_info(s, msg);
	while (!chThdShouldTerminate()) {
		chThdSleepMilliseconds(100);
	}
}

static THD_FUNCTION(ada7seg_thread, arg) {
	struct ada7seg_state *s = (struct ada7seg_state *)arg;
	int rc = 0;
	int idx = 0;

	s->tx = (uint8_t *) ada7seg_malloc(20);
	if (s->tx == NULL) {
		ada7seg_error(s, "out of memory");
		goto exit;
	}
	
	rc = ada7seg_wr8(s, ENABLE_OSCILL);
	if (rc < 0) {
		ada7seg_error(s, "i2c error");
		goto exit;
	}
	ada7seg_wr8(s, BRIGHTNESS+8);
	ada7seg_wr8(s, DISPLAY_ON);
	for (auto i=0; i < 5; ++i)
	{
		s->currentData[i] = 0x0;
	}
	ada7seg_wr8(s, 0, (uint8_t*)s->currentData, 10);

	while (!chThdShouldTerminate()) 
	{
		chThdSleepMilliseconds(10);
		if (s->hasNewValue)
		{
			s->hasNewValue = false;
			ada7seg_wr8(s, 0, (uint8_t*)s->currentData, 10);
		}
	}
 exit:
	chThdExit((msg_t) 0);
}

static void ada7seg_init(struct ada7seg_state *s, i2caddr_t adr=0x70) {
	memset(s, 0, sizeof(struct ada7seg_state));
	s->dev = &I2CD1;
	s->adr = adr;
	s->thd = chThdCreateStatic(s->thd_wa, sizeof(s->thd_wa), NORMALPRIO, ada7seg_thread, (void *)s);
}

static void ada7seg_dispose(struct ada7seg_state *s) {
	chThdTerminate(s->thd);
	chThdWait(s->thd);
}
ada7seg_state ada7seg_state;

void initDisplayData()
{
	uint16_t v[10] = 
	{
	    0b0000000000111111,
	    0b0000000000000110,
	    0b0000000001011011,
	    0b0000000001001111,
	    0b0000000001100110,
	    0b0000000001101101,
	    0b0000000001111101,
	    0b0000000000000111,
	    0b0000000001111111,
	    0b0000000001101111,
	};
	for (int i=0; i < 10; ++i)
	{
		memcpy(ada7seg_state.displayValue, v, sizeof(ada7seg_state.displayValue));
	}
}


void setNewIntValue(int val)
{
	char outb[16];
	ada7seg_state.value = val;
	if (ada7seg_state.hasPrefix)
	{
		chsnprintf(outb, sizeof(outb), "%c%3d", ada7seg_state.prefix, val);
	}
	else
	{
		chsnprintf(outb, sizeof(outb), "%4d", val);
	}
	ada7seg_state.setNewValues(outb, 0);	
}

void setDoubleDot(int val)
{
	ada7seg_state.setDoubleDot(val);
}

void setPrefix(int val)
{
    if (val == -1)
    {
       ada7seg_state.hasPrefix = false;
    }
    else 
    {
    	  ada7seg_state.hasPrefix = true;
    	  ada7seg_state.prefix = val;
    }
    setNewIntValue(ada7seg_state.value);
}]]></code.declaration>
         <code.init><![CDATA[ada7seg_init(&ada7seg_state);

initDisplayData();]]></code.init>
         <code.dispose><![CDATA[ada7seg_dispose(&ada7seg_state);]]></code.dispose>
         <code.krate><![CDATA[static int waitForIt = 6000;
if (waitForIt)
{
	--waitForIt;
	if (!waitForIt)
		LogTextMessage("waiting done");
	return;
}
static int prevValue = -1;
static int prevDblDot = -1;
static int prevPrefix = -1;

if (prevValue != inlet_i1)
{
	prevValue = inlet_i1;
	setNewIntValue(prevValue);
}

if (prevPrefix != inlet_prefixCharacter)
{
	prevPrefix = inlet_prefixCharacter;
	setPrefix(prevPrefix);
}

if (prevDblDot != inlet_dbldot)
{
	prevDblDot = inlet_dbldot;
	setDoubleDot(inlet_dbldot);
}]]></code.krate>
      </object>
   </patchobj>
   <obj type="patch/inlet b" uuid="3b0d3eacb5bb978cb05d1372aa2714d5a4790844" name="doubledot" x="14" y="56">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet i" uuid="f11927f00c59219df0c50f73056aa19f125540b7" name="prefix" x="14" y="98">
      <params/>
      <attribs/>
   </obj>
   <nets>
      <net>
         <source obj="intvalue" outlet="inlet"/>
         <dest obj="mpr121_int_1" inlet="i1"/>
      </net>
      <net>
         <source obj="doubledot" outlet="inlet"/>
         <dest obj="mpr121_int_1" inlet="dbldot"/>
      </net>
      <net>
         <source obj="prefix" outlet="inlet"/>
         <dest obj="mpr121_int_1" inlet="prefixCharacter"/>
      </net>
   </nets>
   <settings>
      <subpatchmode>no</subpatchmode>
      <MidiChannel>1</MidiChannel>
      <NPresets>8</NPresets>
      <NPresetEntries>32</NPresetEntries>
      <NModulationSources>8</NModulationSources>
      <NModulationTargetsPerSource>8</NModulationTargetsPerSource>
   </settings>
   <notes><![CDATA[]]></notes>
   <windowPos>
      <x>89</x>
      <y>450</y>
      <width>720</width>
      <height>439</height>
   </windowPos>
</patch-1.0>