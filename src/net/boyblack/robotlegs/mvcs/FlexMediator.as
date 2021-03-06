package net.boyblack.robotlegs.mvcs
{
	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	public class FlexMediator extends Mediator
	{
		private var uiComponent:UIComponent;

		public function FlexMediator()
		{
			super();
		}

		override public function onRegister():void
		{
			uiComponent = viewComponent as UIComponent;
			if ( uiComponent.initialized )
			{
				onRegisterComplete();
			}
			else
			{
				uiComponent.addEventListener( FlexEvent.CREATION_COMPLETE, onCC, false, 0, true );
			}
		}

		private function onCC( e:FlexEvent ):void
		{
			uiComponent.removeEventListener( FlexEvent.CREATION_COMPLETE, onCC );
			onRegisterComplete();
		}

	}

}