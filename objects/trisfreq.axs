<patch-1.0 appVersion="1.0.12">
   <obj type="mix/mix 3 g" uuid="efc0bdb8ca0ec2184330951eff5203ff487e35a9" name="mix_1" x="602" y="14">
      <params>
         <frac32.u.map name="gain1" value="20.5"/>
         <frac32.u.map name="gain2" value="20.0"/>
         <frac32.u.map name="gain3" value="40.0"/>
      </params>
      <attribs/>
   </obj>
   <obj type="patch/outlet a" uuid="abd8c5fd3b0524a6630f65cad6dc27f6c58e2a3e" name="outlet_1" x="728" y="14">
      <params/>
      <attribs/>
   </obj>
   <obj type="sss/dist/RingMod" uuid="703c4d73-cdf2-4ca9-8f1a-f7d944ff99cb" name="RingMod_1" x="238" y="28">
      <params>
         <int32.hradio name="mode" value="0"/>
         <frac32.u.map name="gain" value="3.5"/>
         <frac32.s.map name="Alvl" value="28.0"/>
         <frac32.s.map name="Blvl" value="52.0"/>
         <frac32.s.map name="Ringlvl" value="64.0"/>
      </params>
      <attribs/>
   </obj>
   <obj type="patch/inlet a" uuid="b577fe41e0a6bc7b5502ce33cb8a3129e2e28ee5" name="inlet_1" x="28" y="56">
      <params/>
      <attribs/>
   </obj>
   <patchobj type="patch/object" uuid="63e0f057-cb03-42f1-b7f0-671d3b00175f" name="fdbkcomb_1" x="392" y="84">
      <params>
         <frac32.s.map name="a" value="48.0"/>
         <frac32.s.map name="b" value="52.0"/>
      </params>
      <attribs/>
      <object id="patch/object" uuid="63e0f057-cb03-42f1-b7f0-671d3b00175f">
         <sDescription></sDescription>
         <author>Johannes Taelman</author>
         <license>BSD</license>
         <helpPatch>fdbkcomb.axh</helpPatch>
         <inlets>
            <frac32buffer name="in" description="in"/>
            <int32 name="size"/>
         </inlets>
         <outlets>
            <frac32buffer name="out" description="out"/>
         </outlets>
         <displays/>
         <params>
            <frac32.s.map.ratio name="a"/>
            <frac32.s.map.ratio name="b"/>
         </params>
         <attribs/>
         <includes/>
         <code.declaration><![CDATA[int16_t d[1024];
int bufferSize;
int dpos;]]></code.declaration>
         <code.init><![CDATA[for (auto i=0; i < sizeof(d)/sizeof(d[0]); i++)
   d[i] = 0;
dpos = 0;
bufferSize=1024;]]></code.init>
         <code.krate><![CDATA[int32_t a2 = param_a<<4;
int32_t b2 = param_b<<4;

if (bufferSize < inlet_size)
	++bufferSize;

if (bufferSize > inlet_size)
	--bufferSize;]]></code.krate>
         <code.srate><![CDATA[int32_t dout =  d[dpos]<<16;
int32_t din = ___SMMUL(b2,inlet_in);
din = ___SMMLA(a2,dout,din);
d[dpos++] = din>>15;
outlet_out = din;
if (dpos >= bufferSize) 
	dpos = 0;]]></code.srate>
      </object>
   </patchobj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="frequency" x="42" y="238">
      <params/>
      <attribs/>
   </obj>
   <patchobj type="patch/object" uuid="e0384ec7-ded7-4e01-8cd3-2bd2a6f95fd1" name="*_1" x="252" y="280">
      <params/>
      <attribs/>
      <object id="patch/object" uuid="e0384ec7-ded7-4e01-8cd3-2bd2a6f95fd1">
         <sDescription></sDescription>
         <author>jay</author>
         <license>BSD</license>
         <helpPatch>timeri.axh</helpPatch>
         <inlets>
            <frac32 name="f"/>
         </inlets>
         <outlets>
            <int32 name="out"/>
         </outlets>
         <displays/>
         <params/>
         <attribs/>
         <includes/>
         <code.krate><![CDATA[outlet_out = static_cast<int32_t>(round(48000/(inlet_f>>21)));]]></code.krate>
      </object>
   </patchobj>
   <obj type="sss/filter/paraEQ" uuid="d7026ba6-245f-47a7-92a3-66d19d1ee676" name="paraEQ_1" x="532" y="280">
      <params>
         <int32 name="stage" value="1"/>
         <bool32.tgl name="STorMS" value="0"/>
         <int32.hradio name="mode" value="0"/>
         <frac32.s.map name="freq" value="-7.0"/>
         <frac32.u.map name="reso" value="26.5"/>
         <frac32.s.map name="gain" value="22.0"/>
         <int32 name="preset" value="0"/>
         <bool32.mom name="save" value="0"/>
         <bool32.mom name="load" value="0"/>
      </params>
      <attribs>
         <spinner attributeName="stages" value="2"/>
      </attribs>
   </obj>
   <obj type="osc/sine lin" uuid="6a4458d598c9b8634b469d1a6e7f87971b5932f" name="sine_1" x="126" y="308">
      <params>
         <frac32.u.map name="freq" value="0.0"/>
      </params>
      <attribs/>
   </obj>
   <nets>
      <net>
         <source obj="inlet_1" outlet="inlet"/>
         <dest obj="RingMod_1" inlet="a"/>
         <dest obj="paraEQ_1" inlet="in"/>
         <dest obj="fdbkcomb_1" inlet="in"/>
      </net>
      <net>
         <source obj="RingMod_1" outlet="result"/>
         <dest obj="mix_1" inlet="in1"/>
      </net>
      <net>
         <source obj="sine_1" outlet="wave"/>
         <dest obj="RingMod_1" inlet="b"/>
      </net>
      <net>
         <source obj="fdbkcomb_1" outlet="out"/>
         <dest obj="mix_1" inlet="in2"/>
      </net>
      <net>
         <source obj="paraEQ_1" outlet="out"/>
         <dest obj="mix_1" inlet="in3"/>
      </net>
      <net>
         <source obj="mix_1" outlet="out"/>
         <dest obj="outlet_1" inlet="outlet"/>
      </net>
      <net>
         <source obj="frequency" outlet="inlet"/>
         <dest obj="sine_1" inlet="freq"/>
         <dest obj="*_1" inlet="f"/>
      </net>
      <net>
         <source obj="*_1" outlet="out"/>
         <dest obj="fdbkcomb_1" inlet="size"/>
      </net>
   </nets>
   <settings>
      <subpatchmode>no</subpatchmode>
   </settings>
   <notes><![CDATA[]]></notes>
   <windowPos>
      <x>340</x>
      <y>172</y>
      <width>872</width>
      <height>591</height>
   </windowPos>
</patch-1.0>