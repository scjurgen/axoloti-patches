<patch-1.0 appVersion="1.0.12">
   <obj type="patch/outlet a" uuid="abd8c5fd3b0524a6630f65cad6dc27f6c58e2a3e" name="outlet_1" x="728" y="14">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet a" uuid="b577fe41e0a6bc7b5502ce33cb8a3129e2e28ee5" name="inlet_1" x="14" y="28">
      <params/>
      <attribs/>
   </obj>
   <obj type="sss/dist/RingMod" uuid="703c4d73-cdf2-4ca9-8f1a-f7d944ff99cb" name="RingMod_1" x="238" y="28">
      <params>
         <int32.hradio name="mode" value="0"/>
         <frac32.u.map name="gain" value="8.0"/>
         <frac32.s.map name="Alvl" value="0.0"/>
         <frac32.s.map name="Blvl" value="0.0"/>
         <frac32.s.map name="Ringlvl" value="64.0"/>
      </params>
      <attribs/>
   </obj>
   <patchobj type="patch/object" uuid="dd92d648-1f8c-4326-8dad-f17588b5f0f1" name="sine_1" x="126" y="112">
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
   <obj type="conv/mtof" uuid="ff3acbab734a93d2098a49e1c4c5d1ad10e0e8bf" name="mtof_1" x="28" y="140">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="frequency" x="14" y="224">
      <params/>
      <attribs/>
   </obj>
   <obj type="combfilter_notedriven" uuid="be69ee47-a136-4340-85db-c53e8c16845c" name="obj_2" x="238" y="266">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="fdbk_ring" x="14" y="322">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="gain_ring" x="14" y="364">
      <params/>
      <attribs/>
   </obj>
   <obj type="vcwah" uuid="38c45de3-4e0d-4aa1-acf7-3a6336f180a2" name="obj_1" x="252" y="392">
      <params>
         <frac32.u.map name="flt:reso" value="62.5"/>
      </params>
      <attribs/>
   </obj>
   <patchobj type="patch/object" uuid="95feb278-e44e-4a2e-b0d2-1ecd0baa6629" name="mix_1" x="490" y="420">
      <params/>
      <attribs/>
      <object id="patch/object" uuid="95feb278-e44e-4a2e-b0d2-1ecd0baa6629">
         <sDescription>3 input s-rate mixer, shows gain units</sDescription>
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
         <code.srate><![CDATA[int32_t accum = ___SMMUL(inlet_in1,inlet_gain1 << 4);
   accum = ___SMMLA(inlet_in2,inlet_gain2 << 4,accum);
   accum = ___SMMLA(inlet_in3,inlet_gain3 << 4,accum);
   outlet_out=  __SSAT(inlet_bus__in + (accum<<1),28);]]></code.srate>
      </object>
   </patchobj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="gain_mix_ring" x="14" y="434">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="gain_mix_comb" x="14" y="490">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="gain_mix_wah_" x="14" y="546">
      <params/>
      <attribs/>
   </obj>
   <nets>
      <net>
         <source obj="inlet_1" outlet="inlet"/>
         <dest obj="RingMod_1" inlet="a"/>
         <dest obj="obj_2" inlet="in"/>
         <dest obj="obj_1" inlet="in"/>
      </net>
      <net>
         <source obj="sine_1" outlet="wave"/>
         <dest obj="RingMod_1" inlet="b"/>
      </net>
      <net>
         <source obj="mix_1" outlet="out"/>
         <dest obj="outlet_1" inlet="outlet"/>
      </net>
      <net>
         <source obj="frequency" outlet="inlet"/>
         <dest obj="obj_2" inlet="pitch"/>
         <dest obj="obj_1" inlet="inlet_1"/>
         <dest obj="mtof_1" inlet="pitch"/>
      </net>
      <net>
         <source obj="obj_2" outlet="outlet_1"/>
         <dest obj="mix_1" inlet="in2"/>
      </net>
      <net>
         <source obj="gain_ring" outlet="inlet"/>
         <dest obj="obj_2" inlet="gain"/>
      </net>
      <net>
         <source obj="fdbk_ring" outlet="inlet"/>
         <dest obj="obj_2" inlet="feedback"/>
      </net>
      <net>
         <source obj="obj_1" outlet="out"/>
         <dest obj="mix_1" inlet="in3"/>
      </net>
      <net>
         <source obj="gain_mix_ring" outlet="inlet"/>
         <dest obj="mix_1" inlet="gain1"/>
      </net>
      <net>
         <source obj="gain_mix_comb" outlet="inlet"/>
         <dest obj="mix_1" inlet="gain2"/>
      </net>
      <net>
         <source obj="gain_mix_wah_" outlet="inlet"/>
         <dest obj="mix_1" inlet="gain3"/>
      </net>
      <net>
         <source obj="mtof_1" outlet="frequency"/>
         <dest obj="sine_1" inlet="freq"/>
      </net>
      <net>
         <source obj="RingMod_1" outlet="result"/>
         <dest obj="mix_1" inlet="in1"/>
      </net>
   </nets>
   <settings>
      <subpatchmode>no</subpatchmode>
   </settings>
   <notes><![CDATA[]]></notes>
   <windowPos>
      <x>273</x>
      <y>75</y>
      <width>1109</width>
      <height>766</height>
   </windowPos>
</patch-1.0>