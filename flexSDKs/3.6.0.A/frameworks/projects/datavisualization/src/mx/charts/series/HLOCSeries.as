////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.charts.series
{

import mx.charts.HitData;
import mx.charts.chartClasses.HLOCSeriesBase;
import mx.charts.renderers.HLOCItemRenderer;
import mx.charts.series.items.HLOCSeriesItem;
import mx.charts.styles.HaloDefaults;
import mx.core.ClassFactory;
import mx.core.mx_internal;
import mx.graphics.IStroke;
import mx.graphics.LinearGradientStroke;
import mx.graphics.Stroke;
import mx.styles.CSSStyleDeclaration;

use namespace mx_internal;
/**
 *  @private
 *  Style used to determine default color of stroke to be used 
 *  when custom IStroke is specified as either stroke, openTickStroke or
 *  closeTickStroke.
 */
[Exclude(name="hlocColor", kind="style")]	//this is private style and excluded from tag inspector
[Style(name="hlocColor", type="uint", format="Color", inherit="no")]

/**
 *  Specifies the length, in pixels, for the close tick mark.
 *  Regardless of this value, an HLOCSeries will not render the close tick
 *  mark outside of the area assigned to the individual element.
 */
[Style(name="closeTickLength", type="Number", format="Length", inherit="no")]

/**
 *  Specifies the stroke to use for the close tick mark
 *  if an opening value is specified.
 */
[Style(name="closeTickStroke", type="mx.graphics.IStroke", inherit="no")]

/**
 *  Sets the stroke style for this data series.
 *  You must specify a Stroke object to define the stroke. 
 */
[Style(name="stroke", type="mx.graphics.IStroke", inherit="no")]

/**
 *  Specifies the length, in pixels, for the open tick mark
 *  if an opening value is specified.
 *  Regardless of this value, an HLOCSeries will not render the open tick
 *  mark outside of the area assigned to the individual element.
 */
[Style(name="openTickLength", type="Number", format="Length", inherit="no")]

/**
 *  Specifies the stroke to use for the open tick mark
 *  if an opening value is specified.
 */
[Style(name="openTickStroke", type="mx.graphics.IStroke", inherit="no")]

/**
 *  Represents financial data as a series of elements
 *  representing the high, low, closing, and, optionally, opening values
 *  of a data series.
 *  The top and bottom of the vertical line in each element
 *  represent the high and low values for the datapoint.
 *  The right-facing tick mark represents the closing value,
 *  and the left tick mark represents the opening value, if one was specified. 
 * 
 *  @mxml
 *  
 *  <p>The <code>&lt;mx:HLOCSeries&gt;</code> tag inherits all the properties
 *  of its parent classes, and adds the following properties:</p>
 *  
 *  <pre>
 *  &lt;mx:HLOCSeries
 *    <strong>Styles</strong>
 *    closeTickLength="<i>No default</i>"
 *    closeTickStroke="<i>No default</i>"
 *    openTickLength="<i>No default</i>"
 *    openTickStroke="<i>No default</i>"
 *    stroke="<i>No default</i>"
 *  /&gt;
 *  </pre>
 * 
 *  @see mx.charts.HLOCChart
 *  
 *  @includeExample ../examples/HLOCChartExample.mxml
 *  
 */
public class HLOCSeries extends HLOCSeriesBase
{
    include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class initialization
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static var stylesInited:Boolean = initStyles();	
	
	/**
	 *  @private
	 */
	private static function initStyles():Boolean
	{
		HaloDefaults.init();

		var hlocSeriesStyle:CSSStyleDeclaration =
			HaloDefaults.createSelector("HLOCSeries");		

		hlocSeriesStyle.defaultFactory = function():void
		{
			this.closeTickLength = 3;
			this.closeTickStroke= new Stroke(0, 3, 1, false, "normal", "none");
			this.itemRenderer = new ClassFactory(HLOCItemRenderer);
			this.openTickLength = 3;
			this.openTickStroke= new Stroke(0, 3, 1, false, "normal", "none");
			this.stroke = new Stroke(0, 0);
			this.hlocColor = 0;
		}

		return true;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */	
	public function HLOCSeries()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
	/**
     *  @private
     */
    override public function getAllDataPoints():Array /* of HitData */
    {
    	if(!_renderData)
    		return [];
    	if(!(_renderData.filteredCache))
    		return [];
    	
    	var itemArr:Array /* of HLOCSeriesItem */ = [];
    	if(chart && chart.dataTipItemsSet && dataTipItems)
    		itemArr = dataTipItems;
    	else if(chart && chart.showAllDataTips && _renderData.filteredCache)
    		itemArr = _renderData.filteredCache;
    	else
    		itemArr = [];
    	
    	var len:uint = itemArr.length;
    	var i:uint;
    	var result:Array /* of HitData */ = [];
    	
    	for (i=0;i<len;i++)
        {
            var v:HLOCSeriesItem = itemArr[i];
            if(_renderData.filteredCache.indexOf(v) == -1)
            {
            	var itemExists:Boolean = false;
            	for (var j:int = 0; j < _renderData.filteredCache.length; j++)
            	{
            		if(v.item == _renderData.filteredCache[j].item)
            		{	
            			v = _renderData.filteredCache[j];
            			itemExists = true;
            			break;
            		}
            	}
            	if(!itemExists)
            		continue;
            }
            if (v)
        	{
            	var ypos:Number = _openField != "" ?
							  (v.open + v.close) / 2 :
							  v.close;

				var id:int = v.index;
			
				var hd:HitData = new HitData(createDataID(id), Math.sqrt(0),
										 v.x + _renderData.renderedXOffset,
										 ypos, v);

				var istroke:IStroke;
				var gb:LinearGradientStroke;
			
				istroke= getStyle("stroke");
				if (istroke is Stroke)
				{
					hd.contextColor = Stroke(istroke).color;
				}
				else if (istroke is LinearGradientStroke)
				{
					gb = LinearGradientStroke(istroke);
					if (gb.entries.length > 0)
						hd.contextColor = gb.entries[0].color;
				}
			
				hd.dataTipFunction = formatDataTip;
            	result.push(hd);
        	}
        }
        return result;
    }

	/**
	 *  @private
	 */	
	override public function findDataPoints(x:Number, y:Number,
											sensitivity:Number):Array /* of HitData */
	{
		// esg, 8/7/06: if your mouse is over a series when it gets added and displayed for the first time, this can get called
		// before updateData, and before and render data is constructed. The right long term fix is to make sure a stubbed out 
		// render data is _always_ present, but that's a little disruptive right now.
		if (interactive == false || !_renderData)
			return [];
			
		var minDist:Number = _renderData.renderedHalfWidth;
		
		var strokeLength:Number = getStyle("closeTickLength");
		if (openField != "" && openField != null)
			strokeLength += getStyle("openTickLength");
		
		if (minDist > strokeLength)
			minDist = strokeLength;
		minDist += sensitivity;
		
		var minItem:HLOCSeriesItem;		

		var len:int = _renderData.filteredCache.length;		
		for (var i:int = 0; i < len; i++)
		{
			var v:HLOCSeriesItem = _renderData.filteredCache[i];
			
			var dist:Number = Math.abs((v.x + _renderData.renderedXOffset) - x);
			if (dist > minDist)
				continue;
				
			var lowValue:Number = Math.max(v.low,Math.max(v.high,v.close));
			var highValue:Number = Math.min(v.low,Math.min(v.high,v.close));
			if(!isNaN(v.open)) 
			{
				lowValue = Math.max(lowValue,v.open);
				highValue = Math.min(highValue,v.open);
			}

			if (highValue- y > sensitivity)
				continue;
			if (y - lowValue > sensitivity)
				continue;
				
			minDist = dist;
			minItem = v;
			if (dist < _renderData.renderedHalfWidth)
			{
				// We're actually inside the column, so go no further.
				break;
			}
		}

		if (minItem)
		{
			var ypos:Number = _openField != "" ?
							  (minItem.open + minItem.close) / 2 :
							  minItem.close;

			var id:int = minItem.index;
			
			var hd:HitData = new HitData(createDataID(id), Math.sqrt(minDist),
										 minItem.x + _renderData.renderedXOffset,
										 ypos, minItem);

			var istroke:IStroke;
			var gb:LinearGradientStroke;
			
			istroke= getStyle("stroke");
			if (istroke is Stroke)
			{
				hd.contextColor = Stroke(istroke).color;
			}
			else if (istroke is LinearGradientStroke)
			{
				gb = LinearGradientStroke(istroke);
				if (gb.entries.length > 0)
					hd.contextColor = gb.entries[0].color;
			}
			
			hd.dataTipFunction = formatDataTip;
			
			istroke = getStyle("stroke");
			if (istroke is Stroke)
			{
				hd.contextColor = Stroke(istroke).color;
			}
			else if (istroke is LinearGradientStroke)
			{
				gb = LinearGradientStroke(istroke);
				if (gb.entries.length > 0)
					hd.contextColor = gb.entries[0].color;
			}
						
			return [ hd ];
		}

		return [];
	}
}

}
