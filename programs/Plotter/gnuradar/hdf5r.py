import xml.etree.ElementTree as ET
import numpy as np

class Reader:

   def __getRoot(self):

      HEADER_FILE = '/dev/shm/GnuRadarHeader.xml'
      root = ET.parse( HEADER_FILE )
      return root

   def __getElement( self, root, name ):
      return int( root.find(name).text )

   def __getElements( self, root, name ):
      return root.findall(name)

   def __init__(self):

      root = self.__getRoot()
      self.sampleRate = self.__getElement(root, 'sample_rate')
      self.channels = self.__getElement(root, 'channels')
      ipps = self.__getElement(root, 'ipps')
      samples = self.__getElement(root, 'samples')
      self.windows = self.__getElements(root, 'rx_win')
      self.dType = np.dtype([('real', np.int16), ('imag', np.int16)])
      self.shape = (ipps*self.channels, samples*self.channels)

   def getBuffer(self):

      root = self.__getRoot()
      index = int( self.__getElement( root, 'tail' ) )
      fileName = '/dev/shm/GnuRadar' + str(index) + '.buf'
      fd = 0
      fd = open( fileName, 'rb' )
      data = np.fromfile( fd, dtype=self.dType ).reshape(self.shape) 
      return data

   def getWindows(self):
      return self.windows

   def getSampleRate(self):
      return self.sampleRate

   def getChannels(self):
      return self.channels

   def getSamples(self):
      return self.shape[1]

   def getIpps(self):
      return self.shape[0]

