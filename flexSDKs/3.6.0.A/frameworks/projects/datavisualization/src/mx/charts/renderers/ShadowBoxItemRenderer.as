////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.charts.renderers
{

import flash.display.Graphics;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import mx.charts.chartClasses.GraphicsUtilities;
import mx.graphics.IFill;
import mx.graphics.IStroke;
import mx.skins.ProgrammaticSkin;
import mx.core.IDataRenderer;
import mx.graphics.SolidColor;
import mx.utils.ColorUtil;
import mx.charts.ChartItem;
import mx.styles.StyleManager;

/**
 *  A simple chart itemRenderer implementation
 *  that fills a rectangular area and surrounds it with a drop shadow.
 *  This class can be used as an itemRenderer for ColumnSeries, BarSeries, AreaSeries, LineSeries,
 *  PlotSeries, and BubbleSeries objects.
 *  It renders its area on screen using the <code>fill</code> and <code>stroke</code> styles
 *  of its associated series.
 */
public class ShadowBoxItemRenderer extends ProgrammaticSkin implements IDataRenderer
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static var FILTERS:Array =
		[ new DropShadowFilter(2, 45, 0.2 * 0xFFFFFF) ];
	
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static var rcFill:Rectangle = new Rectangle();
	
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function ShadowBoxItemRenderer() 
	{
		super();

		filters = FILTERS;
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
	//  data
    //----------------------------------

	/**
	 *  @private
	 *  Storage for the data property.
	 */
	private var _data:Object;

	[Inspectable(environment="none")]

	/**
	 *  The chartItem that this itemRenderer is displaying.
	 *  This value is assigned by the owning series
	 */
	public function get data():Object
	{
		return _data;
	}

	/**
	 *  @private
	 */
	public function set data(value:Object):void
	{
		if (_data == value)
			return;
		_data = value;
	}

	//--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
												   unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		var fill:IFill;
		var state:String = "";
		
		if(_data is ChartItem && _data.hasOwnProperty('fill'))
		{
		 	fill = _data.fill;
		 	state = _data.currentState;
		}
		else
		 	fill = GraphicsUtilities.fillFromStyle(getStyle('fill'));
        
        var color:uint;
		var adjustedRadius:Number = 0;
		
		switch(state)
		{
			case ChartItem.FOCUSED:
			case ChartItem.ROLLOVER:
				if(StyleManager.isValidStyleValue(getStyle('itemRollOverColor')))
					color = getStyle('itemRollOverColor');
				else
					color = ColorUtil.adjustBrightness2(GraphicsUtilities.colorFromFill(fill),-20);
				fill = new SolidColor(color);
				adjustedRadius = getStyle('adjustedRadius');
				if(!adjustedRadius)
					adjustedRadius = 0;
				break;
			case ChartItem.DISABLED:
				if(StyleManager.isValidStyleValue(getStyle('itemDisabledColor')))
					color = getStyle('itemDisabledColor');
				else	
					color = ColorUtil.adjustBrightness2(GraphicsUtilities.colorFromFill(fill),20);
				fill = new SolidColor(GraphicsUtilities.colorFromFill(color));
				break;
			case ChartItem.FOCUSEDSELECTED:
			case ChartItem.SELECTED:
				if(StyleManager.isValidStyleValue(getStyle('itemSelectionColor')))
					color = getStyle('itemSelectionColor');
				else
					color = ColorUtil.adjustBrightness2(GraphicsUtilities.colorFromFill(fill),-30);
				fill = new SolidColor(color);
				adjustedRadius = getStyle('adjustedRadius');
				if(!adjustedRadius)
					adjustedRadius = 0;
				break;
		}
		   
		var stroke:IStroke = getStyle("stroke");
				
		var w:Number = stroke ? stroke.weight / 2 : 0;

		rcFill.left = rcFill.left - adjustedRadius;
		rcFill.top = rcFill.top - adjustedRadius;
		rcFill.right = unscaledWidth;
		rcFill.bottom = unscaledHeight;

		var g:Graphics = graphics;
		g.clear();		
		g.moveTo(w - adjustedRadius, w - adjustedRadius);
		if (stroke)
			stroke.apply(g);
		if (fill)
			fill.begin(g, rcFill);
		g.lineTo(unscaledWidth - w + 2 * adjustedRadius, w - adjustedRadius);
		g.lineTo(unscaledWidth - w + 2 * adjustedRadius, unscaledHeight + 2 * adjustedRadius - w);
		g.lineTo(w - adjustedRadius, unscaledHeight + 2 * adjustedRadius - w);
		g.lineTo(w - adjustedRadius, w - adjustedRadius);
		if (fill)
			fill.end(g);
	}
}

}
