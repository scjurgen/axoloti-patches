<patch-1.0 appVersion="1.0.12">
   <obj type="patch/inlet a" uuid="b577fe41e0a6bc7b5502ce33cb8a3129e2e28ee5" name="in" x="0" y="14">
      <params/>
      <attribs/>
   </obj>
   <obj type="dist/rectifier" uuid="a994d72e4491dedd2655b7a06a4a3f38fcca68d2" name="rectifier_2" x="84" y="14">
      <params/>
      <attribs/>
   </obj>
   <obj type="filter/vcf3" uuid="92455c652cd098cbb682a5497baa18abbf2ef865" name="flt" x="196" y="98">
      <params>
         <frac32.s.map name="pitch" value="13.0"/>
         <frac32.u.map name="reso" onParent="true" value="58.5"/>
      </params>
      <attribs/>
   </obj>
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
   <nets>
      <net>
         <source obj="smooth_1" outlet="out"/>
         <dest obj="flt" inlet="pitch"/>
      </net>
      <net>
         <source obj="in" outlet="inlet"/>
         <dest obj="rectifier_2" inlet="in"/>
      </net>
      <net>
         <source obj="flt" outlet="out"/>
         <dest obj="out" inlet="outlet"/>
      </net>
      <net>
         <source obj="inlet_1" outlet="inlet"/>
         <dest obj="smooth_1" inlet="in"/>
      </net>
      <net>
         <source obj="rectifier_2" outlet="out"/>
         <dest obj="flt" inlet="in"/>
      </net>
   </nets>
   <settings>
      <subpatchmode>no</subpatchmode>
   </settings>
   <notes><![CDATA[]]></notes>
   <windowPos>
      <x>934</x>
      <y>561</y>
      <width>660</width>
      <height>436</height>
   </windowPos>
   <helpPatch>wah1.axh</helpPatch>
</patch-1.0>