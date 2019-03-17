<patch-1.0 appVersion="1.0.12">
   <obj type="mix/mix 3 g" uuid="efc0bdb8ca0ec2184330951eff5203ff487e35a9" name="mix_1" x="602" y="14">
      <params>
         <frac32.u.map name="gain1" value="0.0"/>
         <frac32.u.map name="gain2" value="29.5"/>
         <frac32.u.map name="gain3" value="0.0"/>
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
         <frac32.s.map name="Blvl" value="30.0"/>
         <frac32.s.map name="Ringlvl" value="24.0"/>
      </params>
      <attribs/>
   </obj>
   <obj type="patch/inlet a" uuid="b577fe41e0a6bc7b5502ce33cb8a3129e2e28ee5" name="inlet_1" x="28" y="56">
      <params/>
      <attribs/>
   </obj>
   <obj type="osc/sine lin" uuid="6a4458d598c9b8634b469d1a6e7f87971b5932f" name="sine_1" x="112" y="112">
      <params>
         <frac32.u.map name="freq" value="0.0"/>
      </params>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="frequency" x="14" y="224">
      <params/>
      <attribs/>
   </obj>
   <obj type="combfilter_notedriven" uuid="3d2e4da8-de21-41a4-ba65-1c5b9cd7fb5a" name="obj_2" x="238" y="266">
      <params/>
      <attribs/>
   </obj>
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="gain_ring" x="14" y="308">
      <params/>
      <attribs/>
   </obj>
   <obj type="sss/filter/paraEQ" uuid="d7026ba6-245f-47a7-92a3-66d19d1ee676" name="paraEQ_1" x="406" y="322">
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
   <obj type="patch/inlet f" uuid="5c585d2dcd9c05631e345ac09626a22a639d7c13" name="fdbk_ring" x="14" y="364">
      <params/>
      <attribs/>
   </obj>
   <nets>
      <net>
         <source obj="inlet_1" outlet="inlet"/>
         <dest obj="RingMod_1" inlet="a"/>
         <dest obj="paraEQ_1" inlet="in"/>
         <dest obj="obj_2" inlet="in"/>
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
         <dest obj="obj_2" inlet="pitch"/>
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
   </nets>
   <settings>
      <subpatchmode>no</subpatchmode>
   </settings>
   <notes><![CDATA[]]></notes>
   <windowPos>
      <x>167</x>
      <y>398</y>
      <width>1109</width>
      <height>766</height>
   </windowPos>
</patch-1.0>