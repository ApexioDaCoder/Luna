LuaTerm v2.0beta
(C) 2013 Jim Bauwens

-----------
-- About --
-----------

LuaTerm is a nice Lua terminal for the TI-Nspire. It implements a custom monospace font routine, history support and input editing.
It is built upon a powerful Session and Console library that implements cooperative multitasking.

--------------
-- Using it --
--------------

Send the TNS to your handheld and run it. If you don't know what to do next, LuaTerm probably isn't for you.

------------------------------
-- LuaTerm spefic functions --
------------------------------

print(...)      : print to the console
clear()         : clear the console
sleep(n)        : sleep n seconds. Please note that this lets the execSession sleep, so if you want to sleep another session use yourSession:sleep(n)
readLine([str]) : reads console input. Please note, that just as sleep this is linked to the session execSession, don't use it in other sessions. If str is specified, it will be preinserted in the input stream.

gcct()          : List all (registered) sessions
browse([tbl])   : Browse the global enviroment. If tbl is specified, browse that instead.
 
getConsole() : returns the Console object 
getSession() : returns the execSession Session object


The following documentation is not needed to use LuaTerm; it just describes the internal classes used by LuaTerm.
But you can also use them from within the console.

--------------
-- Sessions --
--------------

There are two sessions used by default:
luaTermSession and execSession.

luaTermSession implements the entire input handling and terminal functionality.
After the user enters a command, it will dynamically generate the execSession, suspend itself, pass control to execSession.
After execSession is completed, it will resume luaTermSession and pass the results to it.

-------------------
-- Console class --
-------------------

Console()                     : create a new Console object

.cursorX                      : cursor column
.cursorY                      : cursor row
.cursorVisisble               : boolean, show/hide the cursor
.height                       : height (in px) of the console
.width                        : width (in px) of the console
.rows                         : amount of rows
.cols                         : amount of collumns
.linesMoved                   : how many lines the console shifted during its lifecycle
.lineBuffer                   : table representing the console buffer

:fit([w], [h])                : resize the console. If parameters ommited it will use the display size
:draw(gc)                     : draw the console to the specified graphical context
:moveUp()                     : shift the console buffer one line. Internally used by :write
:write(str, [ignoreCursor])   : write str to the console (at the location of the cursor). If ignoreCursor is specied and true, the cursor position will not be updated after writing.
:print(...)                   : print the arguments to the console plus a new line
:clear()                      : clear the console
:read(session)                : reads one character. You need to supply a session; and you may only call it from within that session. (otherwise the world can collapse)
:readLine(session, [str])     : reads a line. You can prefill the line with str. Same session restrictions as read
:dataIn(str)                  : used to send data to the console. This data will eventually be parsed by read[Line]
:cursorBack()                 : move the cursor back
:cursorForward()              : move the cursor forward

-----------------------------------------
--           Session class             --
-- implements cooperative multitasking --
-----------------------------------------

Session(console, func, [callback], [commandTable])
                               : create a new Session from func with console as console. If specified, callback will get called when the Session object ends. The thread state and result will be passed as argument to the function. commandTable is used to define functions that can be called using :sendCommand to the Session object.
			      
Session.addSession(session)    : register a Session object
Session.removeSession(session) : unregister a Session object
Session.updateSessions()       : 'tick' all registered Session objects
Session.getSessions()          : return the registered Session object table. Warning: this is a reference! Don't mess with it.

.thread                        : the coroutine behind everything
.console                       : the sessions Console object
.callback                      : the callback function
.commandTable                  : the commandTable
.started                       : true if the Session object has been started
.suspended                     : true if the Session object has been suspended
.nextTick                      : time when the Session may resume its thread

:checkSession(state, ...)      : internally used the check the thread state
:start([run])                  : start the session. If run is specified and true, the session will wait until the next global tick to start the thread
:suspend()                     : suspend the session
:interrupt()                   : interrupt the session
:triggerResume()               : session will resume on next tick
:sleep(n)                      : let the session sleep for n seconds
:tick([forcetick])             : tick the session. If forcetick is true, it will tick regardless if the session is suspended or nextTick isn't due yet
:sendCommand(command, ...)     : call command out of commandTable and pass the arguments. Warning, this is not thread safe!

-- Aliases to the console functions
:print(...)
:write(str)
:read()
:readLine(str)