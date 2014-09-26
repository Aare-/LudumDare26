package com.subfty.sub.svg.actors;

import com.subfty.sub.data.Config;
import nme.geom.Matrix;
import nme.text.TextField;

/**
 * ...
 * @author Filip Loster
 */

class SVGTextField extends TextField{

	public function new(xml:Xml) {
		super();
		Config.formatTextField(this, xml);
	}
	
}