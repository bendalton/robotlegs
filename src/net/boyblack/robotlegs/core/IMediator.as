package net.boyblack.robotlegs.core
{

	/**
	 * The interface definition for a RobotLegs Mediator
	 */
	public interface IMediator
	{
		/**
		 * Should be invoked by the <code>IMediatorFactory</code> when the <code>IMediator</code> has been registered
		 */
		function onRegister():void;

		/**
		 * Should be invoked by the <code>IMediator</code> itself when it is ready to be interacted with
		 * Override and place your initialization code here
		 */
		function onRegisterComplete():void;

		/**
		 * Invoked when the <code>IMediator</code> has been removed by the <code>IMediatorFactory</code>
		 */
		function onRemove():void;

		/**
		 * Should be invoked by the <code>IMediator</code> itself when it is ready to for cleanup
		 * Override and place your cleanup code here
		 */
		function onRemoveComplete():void;

		/**
		 * Get the <code>IMediator</code>'s view component
		 * @return The view component
		 */
		function getViewComponent():Object;

		/**
		 * Set the <code>IMediator</code>'s view component
		 * @param The view component
		 */
		function setViewComponent( viewComponent:Object ):void;

	}
}