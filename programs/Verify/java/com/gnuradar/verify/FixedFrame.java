package com.gnuradar.verify;

import javax.swing.JFrame;

public class FixedFrame extends JFrame 
{
   private static final long serialVersionUID = 1L;

   public FixedFrame( int width, int height, String title )
   {
      setTitle( title );
      setSize( width, height );
      setResizable( false );
   }
}
