<patch-1.0 appVersion="1.0.12">
   <patchobj type="patch/object" uuid="2710898e-2b1c-4e0f-9622-45723d38b985" name="fdbkcomb_2" x="336" y="14">
      <params/>
      <attribs/>
      <object id="patch/object" uuid="2710898e-2b1c-4e0f-9622-45723d38b985">
         <sDescription>samplesize variant combfilter</sDescription>
         <author>Jürgen Schwietering</author>
         <license>BSD</license>
         <helpPatch>fdbkcomb.axh</helpPatch>
         <inlets>
            <frac32buffer name="in" description="in"/>
            <frac32 name="noteheight" description=""/>
            <frac32.bipolar name="fdbkTime" description="feedback time in seconds"/>
         </inlets>
         <outlets>
            <frac32buffer name="out" description="out"/>
         </outlets>
         <displays/>
         <params/>
         <attribs/>
         <includes/>
         <code.declaration><![CDATA[int32_t *d;
int32_t dpos;
int32_t currentWidth;
int32_t newWidth;
int32_t lastF;
int32_t step;
int32_t fdbk_gain;
int32_t fdbkTime;
int32_t totalGain;

void calcFeedBack(int32_t width)
{
	float t = q27_to_float(fdbkTime);
     float p = 48000.0f/width*t;
	if (t >=0)
	{
     	fdbk_gain = float_to_q27(powf(10.0f, (1.0f / p * log(0.333f))));
	}
	else
	{
     	fdbk_gain = float_to_q27(-powf(10.0f, (1.0f / -p * log(0.333f))));
	}
	if (fdbk_gain > 0)
		totalGain = (1<<27) - fdbk_gain/2;
	else
		totalGain = (1<<27) + fdbk_gain/2;
	//LogTextMessage("ring size: %d t=%f fdbk_gain %f , totalGain %f", width, q27_to_float(fdbkTime), q27_to_float(fdbk_gain), q27_to_float(totalGain));
}]]></code.declaration>
         <code.init><![CDATA[#define ADJUST_WIDTH 5
#define MAXSAMPLES_LOWNOTE 1600

static int32_t _array[MAXSAMPLES_LOWNOTE]  __attribute__ ((section (".sdram")));
d = &_array[0];

int i;
for (i = 0; i < MAXSAMPLES_LOWNOTE; i++)
   d[i] = 0;
dpos = 0;
step = 0;
lastF = 1<<27;
currentWidth = 120;]]></code.init>
         <code.krate><![CDATA[static int32_t old_time = 0;

if (old_time != inlet_fdbkTime)
{
	fdbkTime = inlet_fdbkTime;
	calcFeedBack(currentWidth);
	old_time = inlet_fdbkTime;
}

if (lastF != inlet_noteheight) 
{
	int32_t freq;
	MTOF(inlet_noteheight, freq);
	newWidth = static_cast<int32_t>(0.5f+32.0f/q27_to_float(freq));     
	lastF = inlet_noteheight;
	if (newWidth < 10)
		newWidth = 10;
	if (newWidth >= MAXSAMPLES_LOWNOTE)
		newWidth = MAXSAMPLES_LOWNOTE-1;
	calcFeedBack(newWidth);
}

if (--step < 0)
{
	step = ADJUST_WIDTH;
	if (newWidth > currentWidth)
		++currentWidth;
	if (newWidth < currentWidth)
		--currentWidth;
}]]></code.krate>
         <code.srate><![CDATA[int32_t dout =  d[dpos];
int32_t din = ___SMMUL(fdbk_gain, dout) << 5;
din += inlet_in;
 
d[dpos++] = din;
if (dpos >= currentWidth)
	dpos = 0;
din = ___SMMUL(din, totalGain) << 5;
outlet_out = din;]]></code.srate>
      </object>
   </patchobj>
   <obj type="patch/inlet a" uuid="b577fe41e0a6bc7b5502ce33cb8a3129e2e28ee5" name="audioin" x="14" y="28">
      <params/>
      <attribs/>
   </obj>
   <obj type="sss/dist/RingMod" uuid="703c4d73-cdf2-4ca9-8f1a-f7d944ff99cb" name="RingMod_1" x="336" y="126">
      <params>
         <int32.hradio name="mode" value="0"/>
         <frac32.u.map name="gain" value="8.0"/>
         <frac32.s.map name="Alvl" value="0.0"/>
         <frac32.s.map name="Blvl" value="0.0"/>
         <frac32.s.map name="Ringlvl" value="64.0"/>
      </params>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="pitch" x="14" y="140">
      <params/>
      <attribs/>
   </obj>
   <obj type="conv/mtof" uuid="ff3acbab734a93d2098a49e1c4c5d1ad10e0e8bf" name="mtof_1" x="154" y="182">
      <params/>
      <attribs/>
   </obj>
   <patchobj type="patch/object" uuid="dd92d648-1f8c-4326-8dad-f17588b5f0f1" name="sine_1" x="238" y="182">
      <params>
         <frac32.s.map name="freq" value="0.0"/>
      </params>
      <attribs/>
      <object id="patch/object" uuid="dd92d648-1f8c-4326-8dad-f17588b5f0f1">
         <sDescription>sine wave oscillator
linear frequency input (goes all the way to 0)</sDescription>
         <author>Johannes Taelman</author>
         <license>BSD</license>
         <helpPatch>osc.axh</helpPatch>
         <inlets>
            <frac32.bipolar name="freq" description="frequency"/>
         </inlets>
         <outlets>
            <frac32buffer.bipolar name="wave" description="sine wave"/>
         </outlets>
         <displays/>
         <params>
            <frac32.s.map name="freq"/>
         </params>
         <attribs/>
         <includes/>
         <code.declaration><![CDATA[uint32_t Phase;]]></code.declaration>
         <code.init><![CDATA[Phase = 0;]]></code.init>
         <code.srate><![CDATA[Phase += (param_freq + inlet_freq)<<4;
int32_t r;
int32_t p2 = Phase;
SINE2TINTERP(p2,r)
outlet_wave= (r>>4);]]></code.srate>
      </object>
   </patchobj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="comb_feedback" x="14" y="210">
      <params/>
      <attribs/>
   </obj>
   <patchobj type="patch/object" uuid="95feb278-e44e-4a2e-b0d2-1ecd0baa6629" name="mix_1" x="560" y="238">
      <params/>
      <attribs/>
      <object id="patch/object" uuid="95feb278-e44e-4a2e-b0d2-1ecd0baa6629">
         <author>Johannes Taelman</author>
         <license>BSD</license>
         <inlets>
            <frac32buffer name="in1" description="input 1"/>
            <frac32buffer name="in2" description="input 2"/>
            <frac32buffer name="in3" description="input 3"/>
            <frac32 name="gain1"/>
            <frac32 name="gain2"/>
            <frac32 name="gain3"/>
         </inlets>
         <outlets>
            <frac32buffer name="out" description="mix out"/>
         </outlets>
         <displays/>
         <params/>
         <attribs/>
         <includes/>
         <code.declaration><![CDATA[int32_t lastGain[3];]]></code.declaration>
         <code.krate><![CDATA[if (inlet_gain1 != lastGain[0])
{
	lastGain[0] = inlet_gain1;
}
if (inlet_gain2 != lastGain[1])
{
	lastGain[1] = inlet_gain2;
}
if (inlet_gain3 != lastGain[2])
{
	lastGain[2] = inlet_gain3;
}]]></code.krate>
         <code.srate><![CDATA[int32_t accum = ___SMMUL(inlet_in1,inlet_gain1 << 4);
accum = ___SMMLA(inlet_in2,inlet_gain2 << 4,accum);
accum = ___SMMLA(inlet_in3,inlet_gain3 << 4,accum);
outlet_out = accum;]]></code.srate>
      </object>
   </patchobj>
   <obj type="patch/outlet a" uuid="abd8c5fd3b0524a6630f65cad6dc27f6c58e2a3e" name="outlet_1" x="756" y="308">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="comb_gain" x="14" y="336">
      <params/>
      <attribs/>
   </obj>
   <patcher type="patch/patcher" uuid="1ed75abd-54f4-4ab4-ad00-2c66c9c5d00b" name="obj_1" x="322" y="392">
      <params>
         <frac32.u.map name="vcf3_1:reso" value="0.0"/>
      </params>
      <attribs/>
      <subpatch appVersion="1.0.12">
         <obj type="patch/inlet a" uuid="b577fe41e0a6bc7b5502ce33cb8a3129e2e28ee5" name="in" x="0" y="14">
            <params/>
            <attribs/>
         </obj>
         <obj type="dist/rectifier" uuid="a994d72e4491dedd2655b7a06a4a3f38fcca68d2" name="rectifier_2" x="84" y="14">
            <params/>
            <attribs/>
         </obj>
         <patchobj type="patch/object" uuid="46afc8f5-692e-432c-89a0-e0d3195435fa" name="vcf3_1" x="238" y="112">
            <params>
               <frac32.s.map name="pitch" value="13.0"/>
               <frac32.u.map name="reso" onParent="true" value="64.0"/>
            </params>
            <attribs/>
            <object id="patch/object" uuid="46afc8f5-692e-432c-89a0-e0d3195435fa">
               <sDescription>2-pole resonant low-pass filter (biquad), filter updated at k-rate</sDescription>
               <author>Johannes Taelman</author>
               <license>BSD</license>
               <helpPatch>filter.axh</helpPatch>
               <inlets>
                  <frac32buffer name="in" description="filter input"/>
                  <frac32 name="pitch" description="pitch"/>
                  <frac32 name="reso" description="filter resonance"/>
               </inlets>
               <outlets>
                  <frac32buffer name="out" description="filter output"/>
               </outlets>
               <displays/>
               <params>
                  <frac32.s.map name="pitch"/>
                  <frac32.u.map.filterq name="reso"/>
               </params>
               <attribs/>
               <includes/>
               <code.declaration><![CDATA[data_filter_biquad_A fd;
]]></code.declaration>
               <code.init><![CDATA[  init_filter_biquad_A(&fd);
]]></code.init>
               <code.krate><![CDATA[  {
      int32_t freq;
      MTOF(param_pitch + inlet_pitch,freq);
      f_filter_biquad_A(&fd,inlet_in,outlet_out,freq,INT_MAX - (__USAT(inlet_reso + param_reso,27)<<4));
   }
]]></code.krate>
            </object>
         </patchobj>
         <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="inlet_1" x="0" y="126">
            <params/>
            <attribs/>
         </obj>
         <obj type="patch/outlet a" uuid="abd8c5fd3b0524a6630f65cad6dc27f6c58e2a3e" name="out" x="448" y="126">
            <params/>
            <attribs/>
         </obj>
         <obj type="math/smooth" uuid="6c5d08c282bb08bff24af85b4891447f99bcbc97" name="smooth_1" x="84" y="182">
            <params>
               <frac32.u.map name="time" value="18.0"/>
            </params>
            <attribs/>
         </obj>
         <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="reso" x="14" y="280">
            <params/>
            <attribs/>
         </obj>
         <nets>
            <net>
               <source obj="smooth_1" outlet="out"/>
               <dest obj="vcf3_1" inlet="pitch"/>
            </net>
            <net>
               <source obj="in" outlet="inlet"/>
               <dest obj="rectifier_2" inlet="in"/>
            </net>
            <net>
               <source obj="vcf3_1" outlet="out"/>
               <dest obj="out" inlet="outlet"/>
            </net>
            <net>
               <source obj="inlet_1" outlet="inlet"/>
               <dest obj="smooth_1" inlet="in"/>
            </net>
            <net>
               <source obj="rectifier_2" outlet="out"/>
               <dest obj="vcf3_1" inlet="in"/>
            </net>
            <net>
               <source obj="reso" outlet="inlet"/>
               <dest obj="vcf3_1" inlet="reso"/>
            </net>
         </nets>
         <settings>
            <subpatchmode>no</subpatchmode>
         </settings>
         <notes><![CDATA[]]></notes>
         <windowPos>
            <x>770</x>
            <y>339</y>
            <width>660</width>
            <height>436</height>
         </windowPos>
         <helpPatch>wah1.axh</helpPatch>
      </subpatch>
   </patcher>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="ring_gain" x="14" y="406">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="wah_gain" x="14" y="462">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="wah_q" x="14" y="504">
      <params/>
      <attribs/>
   </obj>
   <nets>
      <net>
         <source obj="audioin" outlet="inlet"/>
         <dest obj="obj_1" inlet="in"/>
         <dest obj="RingMod_1" inlet="a"/>
         <dest obj="fdbkcomb_2" inlet="in"/>
      </net>
      <net>
         <source obj="sine_1" outlet="wave"/>
         <dest obj="RingMod_1" inlet="b"/>
      </net>
      <net>
         <source obj="pitch" outlet="inlet"/>
         <dest obj="mtof_1" inlet="pitch"/>
         <dest obj="obj_1" inlet="inlet_1"/>
         <dest obj="fdbkcomb_2" inlet="noteheight"/>
      </net>
      <net>
         <source obj="obj_1" outlet="out"/>
         <dest obj="mix_1" inlet="in3"/>
      </net>
      <net>
         <source obj="wah_gain" outlet="inlet"/>
         <dest obj="mix_1" inlet="gain3"/>
      </net>
      <net>
         <source obj="mtof_1" outlet="frequency"/>
         <dest obj="sine_1" inlet="freq"/>
      </net>
      <net>
         <source obj="ring_gain" outlet="inlet"/>
         <dest obj="mix_1" inlet="gain2"/>
      </net>
      <net>
         <source obj="comb_gain" outlet="inlet"/>
         <dest obj="mix_1" inlet="gain1"/>
      </net>
      <net>
         <source obj="RingMod_1" outlet="result"/>
         <dest obj="mix_1" inlet="in2"/>
      </net>
      <net>
         <source obj="fdbkcomb_2" outlet="out"/>
         <dest obj="mix_1" inlet="in1"/>
      </net>
      <net>
         <source obj="comb_feedback" outlet="inlet"/>
         <dest obj="fdbkcomb_2" inlet="fdbkTime"/>
      </net>
      <net>
         <source obj="wah_q" outlet="inlet"/>
         <dest obj="obj_1" inlet="reso"/>
      </net>
      <net>
         <source obj="mix_1" outlet="out"/>
         <dest obj="outlet_1" inlet="outlet"/>
      </net>
   </nets>
   <settings>
      <subpatchmode>no</subpatchmode>
   </settings>
   <notes><![CDATA[]]></notes>
   <windowPos>
      <x>331</x>
      <y>23</y>
      <width>1109</width>
      <height>766</height>
   </windowPos>
</patch-1.0>