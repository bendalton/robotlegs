RobotLegs AS3
=============

RobotLegs AS3 is an event driven MVCS micro-architecture for Flash and Flex applications. It is inspired by the excellent PureMVC framework, but uses Dependency Injection to do away with Singletons, Services Locators and Casting, and provides automatic Mediator registration for View Components.

Currently, RobotLegs makes use of SmartyPantsIOC - an AS3 Dependency Injection framework for Flash and Flex.

No casting! No fetching! No Singletons! You can read more about it on my [blog](http://shaun.boyblack.co.za/blog/robotlegs-as3/).

Installation
------------

**Flex/FlashBuilder:**

Drop RobotLegsLib.swc and SmartyPantsIOC.swc into your "libs" folder.

If you are building a plain ActionScript project you might need to create the "libs" folder manually:

Right click the project, and create a New Folder called "libs".
Right click the project, open "properties", "Flex Build Path", "Library path", and add the folder "libs".

**Other IDEs or Editors:**

Include RobotLegsLib.swc and SmartyPantsIOC.swc in your build path.

Terminology
-----------

RobotLegs AS3 uses the same terminology as PureMVC for many of it's components and concepts, such as:

Mediators, View Components, Proxies and Commands

Collectively, these are referred to as Framework or Context Actors.

RobotLegs does not, however, employ the use of the Facade design pattern or PureMVC's Notification scheme. Instead, RobotLegs uses:

Contexts and Events

Usage
-----

**Facade/Context**

RobotLegs does not make use of the Facade design pattern - instead there is something known as a Context. It's not really the same thing, and is only used to bootstrap your application, and to hold references to shared Context actors.

Typically, when starting a new project, you extend the default Context, provide Dependency Injection and Reflection adapters, and override the startup() method.

Inside the startup() method you bind a couple of Commands to a startup event and then dispatch that event.

    public class HelloFlexContext extends Context
    {
      public function HelloFlexContext( contextView:DisplayObjectContainer )
      {
        super( contextView, new SmartyPantsInjector(), new SmartyPantsReflector() );
      }
      
      override public function startup():void
      {
        commandFactory.mapCommand( ContextEvent.STARTUP, PrepModelCommand, true );
        commandFactory.mapCommand( ContextEvent.STARTUP, PrepControllerCommand, true );
        commandFactory.mapCommand( ContextEvent.STARTUP, PrepServicesCommand, true );
        commandFactory.mapCommand( ContextEvent.STARTUP, PrepViewCommand, true );
        commandFactory.mapCommand( ContextEvent.STARTUP, StartupCommand, true );
        eventBroadcaster.dispatchEvent( new ContextEvent( ContextEvent.STARTUP ) );
      }
    }

Instantiate the Context and pass it a reference to your view. For a Flex application it might look like this:

    <mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" creationComplete="onCC()">
    	<mx:Script>
    		<![CDATA[
    			import net.boyblack.robotlegs.demos.helloflex.HelloFlexContext;
    			private var helloContext:HelloFlexContext;
          
    			private function onCC():void
    			{
    				helloContext = new HelloFlexContext( this );
    			}
    		]]>
    	</mx:Script>
    </mx:Application>

If you are building a plain ActionScript application, your root Sprite (entry point) might look like this:

    package
    {
    	import flash.display.Sprite;
    	import net.boyblack.robotlegs.demos.hello.HelloContext;
      
    	public class HelloActionScript extends Sprite
    	{
    		private var context:HelloContext;
		    
    		public function HelloActionScript()
    		{
    			context = new HelloContext( this );
    		}
    	}
    }

By default, a Context will automatically execute it's startup() method when it's View Component is added to the Stage.

**Commands**

RobotLegs make use of native Flash Player events for framework communication. Much like PureMVC, Commands can be bound to events.

No parameters are passed to a Command's execute method however. Instead, you define the concrete event that will be passed to the Command as a dependency. This relieves you from having to cast the event.

Multiple Commands can be bound to an event type. They will be executed in the order that they were mapped. This is very handy for mapping your startup commands.

To get a reference to the concrete event that triggered a Command, you must declare the event as a Dependency:

    public class TryClearMessages extends Command
    {
    	[Inject]
    	public var event:SystemEvent;
      
    	[Inject]
    	public var userProxy:UserProxy;
      
    	[Inject]
    	public var messageProxy:MessageProxy;
      
    	override public function execute():void
    	{
    		if ( userProxy.userLoggedIn )
    		{
    			messageProxy.clearMessages();
    		}
    		else
    		{
    			contextView.addChild( new LoginPage() );
    		}
    	}
    }

**Mediators**

RobotLegs makes it easy to work with deeply-nested, lazily-instantiated View Components.

You map Mediator classes to View Component classes during startup, or later during runtime, and RobotLegs creates and registers Mediator instances automatically as View Components arrive on the stage (as children of the Context View).

A Mediator is only ready to be interacted with when it's onRegisterComplete method gets called. This is where you should register your listeners.

The default Mediator implementation provides a handy utility method called addEventListenerTo(). You should use this method to register listeners in your Mediator. Doing so allows RobotLegs to automatically remove any listeners when a Mediator gets removed.

A Mediator might look something like this:

    public class HelloFormMediator extends FlexMediator
    {
    	[Inject]
    	public var helloForm:HelloForm;
      
    	[Inject]
    	public var messageProxy:MessageProxy;
      
    	override public function onRegisterComplete():void
    	{
    		// View Listeners
    		addEventListenerTo( helloForm, HelloFormEvent.FORM_SUBMITTED, onFormSubmitted );
    		// Context Listeners
    		addEventListenerTo( eventDispatcher, MessageProxyEvent.MESSAGE_ADDED, whenMessageAdded );
    	}
      
    	private function onFormSubmitted( e:HelloFormEvent ):void
    	{
    		messageProxy.addMessage( helloForm.getMessage() );
    	}
      
    	private function whenMessageAdded( e:MessageProxyEvent ):void
    	{
    		helloForm.messageTxt.setFocus();
    	}
    }

The Mediator above has two dependencies:

- It's View Component: HelloForm
- The MessageProxy

It listens to events from the view, invokes methods on the MessageProxy's API, and listens to the Context's event bus for MessageProxyEvent events.

NOTE: addEventListenerTo() is a convenience method. It keeps track of any listeners registered and removes them when the Mediator is removed.
NOTE: Flex Mediators should extend the FlexMediator Class, but plain ActionScript Mediators can simply extend the default Mediator Class.

**Proxies**

Proxies are much like Mediators, but instead of wrapping View Components, they manage access to data (or Models).

Proxies should not listen to the Context's event bus, and therefore they are provided with one-way EventDispatchers called EventBroadcasters (a simple wrapper around the EventDispatcher that limits it's API).

**Services**

Services are like Proxies, but instead of managing Models, they manage access to remote services.



Links
-----
- [Wiki](http://wiki.github.com/darscan/robotlegs)
- [Library Source](http://github.com/darscan/robotlegs/tree/master)
- [Demo Source](http://github.com/darscan/robotlegsdemos/tree/master)
- [Demo Flex App](http://shaun.boyblack.co.za/flash/robotlegsdemo/HelloFlex.html)
- [Issue Tracking](http://github.com/darscan/robotlegs/issues)
- [Discussion Group](http://groups.google.com/group/robotlegs)
- [Announcement](http://shaun.boyblack.co.za/blog/2009/04/16/robotlegs-an-as3-mvcs-framework-for-flash-and-flex-applications-inspired-by-puremvc/)
- [SmartyPants IOC](http://code.google.com/p/smartypants-ioc/)

License
-------

Copyright (c) 2009 BoyBlack.co.za

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
