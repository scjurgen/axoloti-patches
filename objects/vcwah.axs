<patch-1.0 appVersion="1.0.12">
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
</patch-1.0>