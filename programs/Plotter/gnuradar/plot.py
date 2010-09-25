from gnuradar.hdf5r import Reader
from enthought.enable.wx_backend.api import Window
from enthought.chaco.api import ArrayPlotData, Plot, ColorBar
from enthought.chaco.api import HPlotContainer, LinearMapper
from enthought.chaco.tools.api import RangeSelection, RangeSelectionOverlay
from numpy import ndarray, arange, zeros, log10, clip


# define base plot
class GnuRadarPlot:

   def __init__( self ):
      self.header = Reader()

   def createPlot( self, showDataTag ):
      raise  NotImplementedError( 
            " Abstract method CreatePlot not implented. ")


# define iq plot derived from base plot
class IQPlot( GnuRadarPlot ):

   def __init__( self ):
      GnuRadarPlot.__init__( self )

   def createPlot(self, showDataTag ):
      
      # picks the desired channel out of the interleaved data
      stride = self.header.getChannels()

      # the first sample contains the data tag - the user has the 
      # option to not display with the offset enabled
      offset = 0 if showDataTag else stride

      # we first grab the entire table and then select 1st ipp
      # along with the associated channel we're interested in. 
      # I'm assuming this slice is a reference of the original.
      self.dataView = self.header.getBuffer()[ 0, offset::stride ]

      i = self.dataView['real']
      q = self.dataView['imag']
      xAxis = range( offset, i.size )

      plotData = ArrayPlotData( xAxis=xAxis, i=i , q=q ) 
      plot = Plot( plotData )
      plot.plot( ("xAxis", "i"), type="line", color="blue")
      plot.plot( ("xAxis", "q"), type="line", color="red")
      plot.title = 'IQ Plot'
      
      return plot


# define RTI plot derived from base plot
class RTIPlot( GnuRadarPlot ):

   def __init__( self ):
      GnuRadarPlot.__init__( self )

   def createColorbar(self, colormap):
      colorbar = ColorBar(
            index_mapper=LinearMapper(range=colormap.range),
            color_mapper=colormap,
            orientation='v',
            resizable='v',
            width=30,
            padding=20)

      colorbar.tools.append(RangeSelection(component=colorbar))

      colorbar.overlays.append(
            RangeSelectionOverlay(
               component=colorbar,
               border_color="white",
               alpha=0.8,
               fill_color="lightgray")
            )

      return colorbar

   def createPlot( self, showDataTag ):
      
      # picks the desired channel out of the interleaved data
      stride = self.header.getChannels()

      # the first sample contains the data tag - the user has the 
      # option to not display with the offset enabled
      offset = 0 if showDataTag else stride

      # we first grab the entire table and then select ALL ipps
      # along with the associated channel we're interested in. 
      # I'm assuming this slice is a reference of the original.
      self.dataView = self.header.getBuffer()[ :, offset::stride ]

      i = self.dataView['real']
      q = self.dataView['imag']
      xAxis = range( offset, i.size )

      # compute magnitude
      pwr = ( i**2.00 + q**2.00 )

      # compute power in dB
      pwr = 10*log10(pwr)

      # limit lower data value to -40dB to prevent -inf problems
      pwr = clip(pwr, -40, pwr.max() )

      plotData = ArrayPlotData( pwr=pwr ) 
      plot = Plot( plotData )
      plot.img_plot( 
            'pwr', 
            xbounds=(0,self.header.getSamples()-offset),
            ybounds=(0,self.header.getIpps())
            )
      plot.title = 'RTI Plot'

      colorbar = self.createColorbar( plot.color_mapper )
      container = HPlotContainer( use_backbuffer = True )
      container.add( plot )
      container.add( colorbar )
      
      return container
