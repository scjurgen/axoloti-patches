<patch-1.0 appVersion="1.0.12">
   <obj type="patch/inlet a" uuid="b577fe41e0a6bc7b5502ce33cb8a3129e2e28ee5" name="in" x="42" y="42">
      <params/>
      <attribs/>
   </obj>
   <patchobj type="patch/object" uuid="2710898e-2b1c-4e0f-9622-45723d38b985" name="fdbkcomb_2" x="140" y="70">
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
   <obj type="patch/outlet a" uuid="abd8c5fd3b0524a6630f65cad6dc27f6c58e2a3e" name="outlet_1" x="252" y="70">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="pitch" x="42" y="84">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="feedback" x="42" y="126">
      <params/>
      <attribs/>
   </obj>
   <nets>
      <net>
         <source obj="fdbkcomb_2" outlet="out"/>
         <dest obj="outlet_1" inlet="outlet"/>
      </net>
      <net>
         <source obj="in" outlet="inlet"/>
         <dest obj="fdbkcomb_2" inlet="in"/>
      </net>
      <net>
         <source obj="pitch" outlet="inlet"/>
         <dest obj="fdbkcomb_2" inlet="noteheight"/>
      </net>
      <net>
         <source obj="feedback" outlet="inlet"/>
         <dest obj="fdbkcomb_2" inlet="fdbkGain"/>
      </net>
   </nets>
   <settings>
      <subpatchmode>no</subpatchmode>
   </settings>
   <notes><![CDATA[]]></notes>
   <windowPos>
      <x>319</x>
      <y>274</y>
      <width>836</width>
      <height>484</height>
   </windowPos>
</patch-1.0>