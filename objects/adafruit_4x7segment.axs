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
         <includes/>
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
	uint16_t currentData[5];
	uint16_t displayValue[10];
	
	void setNewValues(char *outb, int size)
	{
		//LogTextMessage("show: %s", outb);
		currentData[2] = 0;
		for (int i=0; i < size; ++i)
		{
			int idx = i>1?i+1:i;
			if (outb[i] == ' ')
				currentData[idx] = 0;
			else
			if (outb[i] == '-')
				currentData[idx] = 0x40;
			else
			if ((outb[i] >= '0') && (outb[i] <= '9'))
			{	
				currentData[idx] = displayValue[outb[i]-'0'];
			}
		}
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
	ada7seg_wr8(s, BRIGHTNESS+5);
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

void int2a(int num, char* str) 
{ 
    bool isNegative = false;
    if (num == 0) 
    { 
        str[0] = '0'; 
        str[1] = 0; 
        return; 
    } 
    if (num < 0) 
    { 
        isNegative = true; 
        num = -num; 
    } 
    char outb[16];
    int idx = 15;
    while (num != 0) 
    { 
        int rem = num % 10; 
        outb[idx--] = (rem > 9)? (rem-10) + 'a' : rem + '0'; 
        num = num/10; 
    } 
    if (isNegative) 
        outb[idx--] = '-'; 
    while (idx++ < 16)
    {
    	  *str++=outb[idx];
    }
    *str = 0;
} 

void setNewIntValue(int val)
{
	char outb[16];
	int2a(val, outb);
	
	ada7seg_state.setNewValues(outb, 4);
}]]></code.declaration>
         <code.init><![CDATA[ada7seg_init(&ada7seg_state);

initDisplayData();]]></code.init>
         <code.dispose><![CDATA[ada7seg_dispose(&ada7seg_state);]]></code.dispose>
         <code.krate><![CDATA[static int prevValue = -1;
static int prevDblDot = -1;
static int prevPrefix = -1;

if (prevValue != inlet_i1)
{
	prevValue = inlet_i1;
	setNewIntValue(prevValue);
}]]></code.krate>
      </object>
   </patchobj>
   <obj type="patch/inlet b" uuid="3b0d3eacb5bb978cb05d1372aa2714d5a4790844" name="doubledot" x="14" y="56">
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
   </nets>
   <settings>
      <subpatchmode>no</subpatchmode>
   </settings>
   <notes><![CDATA[]]></notes>
   <windowPos>
      <x>786</x>
      <y>190</y>
      <width>651</width>
      <height>354</height>
   </windowPos>
</patch-1.0>