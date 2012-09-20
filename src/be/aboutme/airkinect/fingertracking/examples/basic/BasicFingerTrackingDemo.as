package be.aboutme.airkinect.fingertracking.examples.basic
{
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.constants.CameraResolution;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceEvent;
	import com.as3nui.nativeExtensions.air.kinect.examples.DemoBase;
	import com.as3nui.nativeExtensions.air.kinect.frameworks.openni.data.OpenNIUser;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	
	public class BasicFingerTrackingDemo extends DemoBase
	{
		private var depthBitmap:Bitmap;
		private var device:Kinect;
		
		private var fingersView:Shape;
		
		override protected function startDemoImplementation():void
		{
			if(Kinect.isSupported())
			{
				device = Kinect.getDevice();
				
				depthBitmap = new Bitmap();
				addChild(depthBitmap);
				
				device.addEventListener(CameraImageEvent.DEPTH_IMAGE_UPDATE, depthImageUpdateHandler, false, 0, true);
				device.addEventListener(DeviceEvent.STARTED, kinectStartedHandler, false, 0, true);
				device.addEventListener(DeviceEvent.STOPPED, kinectStoppedHandler, false, 0, true);
				
				var settings:KinectSettings = new KinectSettings();
				settings.depthEnabled = true;
				settings.depthResolution = CameraResolution.RESOLUTION_640_480;
				settings.skeletonEnabled = true;
				
				device.start(settings);
				
				fingersView = new Shape();
				addChild(fingersView);
				
				addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
			}
		}
		
		protected function enterFrameHandler(event:Event):void
		{
			fingersView.graphics.clear();
			for each(var user:User in device.usersWithSkeleton)
			{
				if(user is OpenNIUser)
				{
					var openNIUser:OpenNIUser = user as OpenNIUser;
					var finger:SkeletonJoint;
					
					fingersView.graphics.beginFill(0xff0000);
					fingersView.graphics.drawCircle(user.leftHand.position.depth.x, user.leftHand.position.depth.y, 10);
					fingersView.graphics.endFill();

					for each(finger in openNIUser.leftFingers)
					{
						fingersView.graphics.beginFill(0xff0000);
						fingersView.graphics.drawCircle(finger.position.depth.x, finger.position.depth.y, 5);
						fingersView.graphics.endFill();
					}
					
					fingersView.graphics.beginFill(0x00ff00);
					fingersView.graphics.drawCircle(user.rightHand.position.depth.x, user.rightHand.position.depth.y, 10);
					fingersView.graphics.endFill();
					
					for each(finger in openNIUser.rightFingers)
					{
						fingersView.graphics.beginFill(0x00ff00);
						fingersView.graphics.drawCircle(finger.position.depth.x, finger.position.depth.y, 5);
						fingersView.graphics.endFill();
					}
				}
			}
		}
		
		protected function kinectStartedHandler(event:DeviceEvent):void
		{
			trace("[BasicFingerTrackingDemo] kinect started");
		}
		
		protected function kinectStoppedHandler(event:DeviceEvent):void
		{
			trace("[BasicFingerTrackingDemo] kinect stopped");
		}
		
		override protected function stopDemoImplementation():void
		{
			if(device != null)
			{
				device.stop();
				device.removeEventListener(CameraImageEvent.DEPTH_IMAGE_UPDATE, depthImageUpdateHandler);
				device.removeEventListener(DeviceEvent.STARTED, kinectStartedHandler);
				device.removeEventListener(DeviceEvent.STOPPED, kinectStoppedHandler);
			}
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function depthImageUpdateHandler(event:CameraImageEvent):void
		{
			depthBitmap.bitmapData = event.imageData;
			layout();
		}
		
		override protected function layout():void
		{
			fingersView.x = depthBitmap.x = (explicitWidth - depthBitmap.width) * .5;
			fingersView.y = depthBitmap.y = (explicitHeight - depthBitmap.height) * .5;
		}
	}
}