import  wx
from threading import Thread
from enthought.chaco.api import *
from enthought.enable.wx_backend.api import Window
from time import sleep
from gnuradar.hdf5r import Reader 
from gnuradar.plot import IQPlot, RTIPlot

#---------------------------------------------------------------------------
# This class contains a thread that refreshes the plot at a rate defined 
# by the refreshRate variable
#---------------------------------------------------------------------------
class DataPlotter(Thread):

   #def __init__(self, plot, plotData, plotProperties ):
   def __init__( self, plotProperties ):
      Thread.__init__(self)

      self.pp = plotProperties
      self.running = True
      self.iqPlot = IQPlot() 
      self.rtiPlot = RTIPlot()

   def run(self):
      Thread.__init__(self)
      self.running = True

      while( self.running ):

         # determine the selected plot
         if( self.pp.plotType.GetLabelText() == "I/Q Plot" ):
            self.pp.window.component = self.iqPlot.createPlot( 
                  self.pp.dataTagEnabled )
         else:

            if( self.pp.plotType.GetLabelText() == "RTI Plot" ):
               self.pp.window.component = self.rtiPlot.createPlot( 
                     self.pp.dataTagEnabled )

         sleep( self.pp.refreshRate )
         print('running')

   def stop(self):
      self.running = False

class PlotProperties:

   def __init__(self, window, dataTagEnabled, plotType, channel, 
         channels, refreshRate ):
      self.window = window
      self.dataTagEnabled = dataTagEnabled
      self.plotType  = plotType
      self.channel = channel
      self.channels = channels
      self.refreshRate = refreshRate

class Frame(wx.Frame):

   # initialize objects and variables
   def __init__(self, parent, ID, title):

      # initialize parent
      wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, 
            size=( 750,450 ))

      # create a menubar
      menuBar = wx.MenuBar()

      # add a file menu 
      self.fileMenu = wx.Menu()
      self.fileMenu.Append(1, '&Connect', 'Connect to streaming data ')
      self.fileMenu.Append(2, '&SnapShot', 'Take a snap shot of the current image')
      self.fileMenu.Append(3,'&Quit', 'Exit Plotter')
      menuBar.Append( self.fileMenu, '&File')

      # set the application's menubar
      self.SetMenuBar( menuBar )

      # connect menu items to actions
      self.Bind( wx.EVT_MENU, self.OnConnect, id=1)
      self.Bind( wx.EVT_MENU, self.OnSnapShot, id=2)
      self.Bind( wx.EVT_MENU, self.OnClose, id=3)

      # create sizers for layout
      vSizer = wx.BoxSizer( wx.VERTICAL )
      hSizer = wx.BoxSizer( wx.HORIZONTAL )

      # create panels for layout
      mainPanel = wx.Panel(self,-1)
      typePanel = wx.Panel(mainPanel, -1)
      channelPanel = wx.Panel(mainPanel, -1)

      # create radio buttons to select plot type
      typeBox = wx.StaticBox(typePanel, -1, 'Plot Type')
      typeSizer = wx.StaticBoxSizer( typeBox, wx.VERTICAL )
      self.plots = ([
         wx.RadioButton(typePanel, -1, 'I/Q Plot'),
         wx.RadioButton(typePanel, -1, 'RTI Plot'),
         wx.RadioButton(typePanel, -1, 'Doppler Plot', size=(110,20)),
         ])

      # add plot to size and bind event handlers
      for plot in self.plots:
         typeSizer.Add( plot )
         self.Bind( wx.EVT_RADIOBUTTON, self.OnSelectPlotType, plot)

      # provide option to toggle display of the data tag 
      self.dataTagCheckBox = wx.CheckBox( parent=typePanel, 
            label='Show Data Tag' )
      self.dataTagCheckBox.SetValue( True )
      typeSizer.AddSpacer(5)
      typeSizer.Add( self.dataTagCheckBox )

      # bind event handler
      self.Bind( wx.EVT_CHECKBOX, self.OnDataTagSelect, self.dataTagCheckBox )

      # setup adjustable refresh rate - probably not the brightest 
      # of ideas in the long run, but OK for testing
      refreshRate = 1.0 
      refreshRateBoxSizer = wx.BoxSizer( wx.HORIZONTAL )
      self.refreshRateTextCtrl = wx.TextCtrl( mainPanel, size=(40,25));
      self.refreshRateTextCtrl.SetValue( str( refreshRate ) )
      refreshRateButton = wx.Button( mainPanel, label='RefreshRate', 
            size=(110,25))
      refreshRateBoxSizer.Add( refreshRateButton )
      refreshRateBoxSizer.AddSpacer(2)
      refreshRateBoxSizer.Add( self.refreshRateTextCtrl )

      # bind event handler
      self.Bind( wx.EVT_BUTTON, self.OnRefreshRate, refreshRateButton)

      # set the panel's sizer
      typePanel.SetSizer( typeSizer )

      # create radio buttons for channel selection
      channelBox = wx.StaticBox( channelPanel, -1, 'Channels')
      channelSizer = wx.StaticBoxSizer( channelBox, wx.VERTICAL )

      # create channel radio buttons
      self.channels = ([
         wx.RadioButton(channelPanel,-1,'1'),#, size=(120,20)),
         wx.RadioButton(channelPanel,-1,'2'),#, size=(120,20)),
         wx.RadioButton(channelPanel,-1,'3'),#, size=(120,20)),
         wx.RadioButton(channelPanel,-1,'4')#, size=(120,20)),
         ])

      # assign channels to sizer and bind event handlers
      for channel in self.channels:
         channelSizer.Add( channel )
         self.Bind( wx.EVT_RADIOBUTTON, self.OnSelectChannel, channel)

      # initialize with channel 1 active - all others disabled
      for i in range(1,4):
         self.channels[i].Enable(False)

      channelPanel.SetSizer(channelSizer)

      vSizer.Add( typePanel, 1, flag=wx.EXPAND)
      vSizer.Add( channelPanel, 1, flag=wx.EXPAND)
      vSizer.Add( refreshRateBoxSizer,1 , flag=wx.EXPAND)

      hSizer.Add( vSizer )

      # create a plotting window
      self.plotData = ArrayPlotData()
      self.plot = Plot( self.plotData )

      # encapsulate plot object in a window so we can add it to the application.
      window = Window( mainPanel, component=self.plot)

      hSizer.Add( window.control,1, wx.EXPAND)
      
      mainPanel.SetSizer( hSizer )
      mainPanel.SetAutoLayout(True)

      #initialize type of plot to produce and channel to view
      plotType = self.plots[0]
      channel = self.channels[0]
      dataTagEnabled = self.dataTagCheckBox.IsEnabled()

      self.connected = False

      self.pp = PlotProperties( 
            window,
            dataTagEnabled,
            plotType,
            channel,
            1,
            refreshRate)

      self.dataPlotter = DataPlotter( self.pp )

   # when connect is called, attempt to connect to streaming 
   # data in shared memory
   def OnConnect(self,event):

      if( self.connected ):
         self.connected = False
         self.dataPlotter.stop()
         self.fileMenu.SetLabel(1,'&Connect')
      else:
         self.connected = True
         self.pp.channels = hdf5r.Reader().getChannels()
         self.dataPlotter.start()
         self.fileMenu.SetLabel(1,'&Disconnect')

   # take a screen shot
   def OnSnapShot(self,event):
      print( 'snap shot not yet implemented')

   # close the application
   def OnClose(self,event):
      self.Close()

   # adjust the refresh rate
   def OnRefreshRate(self,event):
      self.pp.refreshRate = float( self.refreshRateTextCtrl.GetValue() )

   # select the channel to display
   def OnSelectChannel(self, event):
      value = event.GetEventObject()
      index = self.channels.index( value )
      self.pp.channel = self.channels[ index ]

   # select the plot type to display
   def OnSelectPlotType(self, event):
      value = event.GetEventObject()
      index = self.plots.index( value )
      self.pp.plotType = self.plots[ index ]

   # select whether or not to display the data tag
   def OnDataTagSelect( self, event ):
      self.pp.dataTagEnabled = self.dataTagCheckBox.GetValue()

#---------------------------------------------------------------------------

class GnuRadarPlotter( wx.App ):

   def OnInit(self):
      frame = Frame( None, -1, "GnuRadar Real-time data plotter")
      frame.Show(True)
      self.SetTopWindow(frame)
      return True

#---------------------------------------------------------------------------

def startApplication():
   app = GnuRadarPlotter(0)
   app.MainLoop()

#---------------------------------------------------------------------------

if __name__ == '__main__':
   app = GnuRadarPlotter(0)
   app.MainLoop()

