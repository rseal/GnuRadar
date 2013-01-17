import yaml
import numpy as np

class Reader:

   def __init__(self):
      self.HEADER_FILE = '/dev/shm/GnuRadarHeader.yml'
      self.BUFFER_PREFIX = '/dev/shm/GnuRadar'
      self.BUFFER_EXT = '.buf'
      fid = open(self.HEADER_FILE)
      self.yml = yaml.load(fid)
      fid.close()
      self.dType = np.dtype([('real', np.int16), ('imag', np.int16)])

   def getBuffer(self):
      fileName = self.BUFFER_PREFIX + str(self.yml['tail']) + self.BUFFER_EXT
      fid = open( fileName, 'rb' )
      data = np.fromfile( fd, dtype=self.dType ).reshape(self.shape) 
      fid.close()
      return data

   def getWindows(self):
      return self.yml['rx_win']

   def getSampleRate(self):
      return self.yml['sample_rate']

   def getChannels(self):
      return self.yml['channels']

   def getSamples(self):
      return self.yml['samples']

   def getIpps(self):
      return self.yml['ipps']

