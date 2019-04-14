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
            <frac32.bipolar name="fdbkGain" description="feedback gain"/>
         </inlets>
         <outlets>
            <frac32buffer name="out" description="out"/>
         </outlets>
         <displays/>
         <params/>
         <attribs/>
         <includes/>
         <code.declaration><![CDATA[int32_t d[1600]; // minimum of 30 HZ (bit lower than B0)
int32_t dpos;
int32_t currentWidth;
int32_t newWidth;
int32_t lastF;
int32_t step;]]></code.declaration>
         <code.init><![CDATA[#define ADJUST_WIDTH 4

int i;
for (i = 0; i < sizeof(d)/sizeof(d[0]); i++)
   d[i] = 0;
dpos = 0;
step = 0;
lastF = 1<<27;
currentWidth = 120;]]></code.init>
         <code.krate><![CDATA[

int32_t fdbk_gain = inlet_fdbkGain;

if (lastF != inlet_noteheight) 
{
	int32_t freq;
	MTOF(inlet_noteheight, freq);
	newWidth = static_cast<int32_t>(0.5f+32.0f/q27_to_float(freq));     
	lastF = inlet_noteheight;
	if (newWidth < 10)
		newWidth = 10;
	if (newWidth >= sizeof(d)/sizeof(d[0]))
		newWidth = sizeof(d)/sizeof(d[0])-1;
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
outlet_out = din;]]></code.srate>
      </object>
   </patchobj>
   <obj type="patch/inlet a" uuid="b577fe41e0a6bc7b5502ce33cb8a3129e2e28ee5" name="audioin" x="14" y="28">
      <params/>
      <attribs/>
   </obj>
   <obj type="sss/dist/RingMod" uuid="703c4d73-cdf2-4ca9-8f1a-f7d944ff99cb" name="RingMod_1" x="322" y="126">
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
         <sDescription></sDescription>
         <author>Johannes Taelman</author>
         <license>BSD</license>
         <inlets>
            <frac32buffer name="bus_in" description="input with unity gain"/>
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
	LogTextMessage("new comb gain: %f", q27_to_float(inlet_gain1));
}
if (inlet_gain2 != lastGain[1])
{
	lastGain[1] = inlet_gain2;
	LogTextMessage("new ring gain: %f", q27_to_float(inlet_gain2));
}
if (inlet_gain3 != lastGain[2])
{
	lastGain[2] = inlet_gain3;
	LogTextMessage("new wah gain: %f", q27_to_float(inlet_gain3));
}]]></code.krate>
         <code.srate><![CDATA[int32_t accum = ___SMMUL(inlet_in1,inlet_gain1 << 4);
   accum = ___SMMLA(inlet_in2,inlet_gain2 << 4,accum);
   accum = ___SMMLA(inlet_in3,inlet_gain3 << 4,accum);
   outlet_out=  __SSAT(inlet_bus__in + (accum<<1),28);]]></code.srate>
      </object>
   </patchobj>
   <obj type="patch/outlet a" uuid="abd8c5fd3b0524a6630f65cad6dc27f6c58e2a3e" name="outlet_1" x="756" y="308">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="comb_gain" x="14" y="364">
      <params/>
      <attribs/>
   </obj>
   <obj type="vcwah" uuid="87a62ee1-cddb-43d5-b254-0327ec860891" name="obj_1" x="322" y="364">
      <params>
         <frac32.u.map name="flt:reso" value="62.5"/>
      </params>
      <attribs/>
   </obj>
   <patchobj type="patch/object" uuid="72e0f995-fb6d-4dab-9f1f-15ef742292a4" name="gain_1" x="672" y="364">
      <params/>
      <attribs/>
      <object id="patch/object" uuid="72e0f995-fb6d-4dab-9f1f-15ef742292a4">
         <author>Johannes Taelman</author>
         <license>BSD</license>
         <helpPatch>math.axh</helpPatch>
         <inlets>
            <frac32buffer name="in" description="input"/>
            <frac32 name="gain"/>
         </inlets>
         <outlets>
            <frac32buffer name="out" description="output"/>
         </outlets>
         <displays/>
         <params/>
         <attribs/>
         <includes/>
         <code.srate><![CDATA[outlet_out= __SSAT(___SMMUL(inlet_gain,__SSAT(inlet_in,28)<<4)<<1,28);]]></code.srate>
      </object>
   </patchobj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="ring_gain" x="14" y="406">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="wah_gain" x="14" y="448">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="outgain" x="14" y="490">
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
         <dest obj="obj_1" inlet="inlet_1"/>
         <dest obj="mtof_1" inlet="pitch"/>
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
         <source obj="comb_feedback" outlet="inlet"/>
         <dest obj="fdbkcomb_2" inlet="fdbkGain"/>
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
         <source obj="gain_1" outlet="out"/>
         <dest obj="outlet_1" inlet="outlet"/>
      </net>
      <net>
         <source obj="mix_1" outlet="out"/>
         <dest obj="gain_1" inlet="in"/>
      </net>
      <net>
         <source obj="outgain" outlet="inlet"/>
         <dest obj="gain_1" inlet="gain"/>
      </net>
   </nets>
   <settings>
      <subpatchmode>no</subpatchmode>
   </settings>
   <notes><![CDATA[]]></notes>
   <windowPos>
      <x>159</x>
      <y>90</y>
      <width>1109</width>
      <height>766</height>
   </windowPos>
</patch-1.0>