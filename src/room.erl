%% -*- mode: nitrogen -*-
-module (room).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").
-include("records.hrl").

main() -> #template { file="./site/templates/bare.html" }.

title() -> "Hello from room.erl!".

body() -> 
    wf:comet_global(fun() -> repeater(1) end, repeater_pool),
    [
		#textbox {id=username, text="Ditt användernamn", next=msg},
        #textbox { id=msg, text="Meddelande", next=submit },
        #button { id=submit, text="Submit", postback=submit },
        #panel { id=placeholder }
    ].

event(submit) ->
    ?PRINT(wf:q(msg)),
    wf:send_global(repeater_pool, {msg, wf:q(msg), wf:q(username)}). 

repeater(Users) ->
	
    receive 
		'INIT' ->
				%% The init message is sent to the first process in a comet pool.
		        Message = [
		        	#p{},
		         	#span { text="Du är ensam i rummet.", class=message }
		         ],
		         wf:insert_bottom(placeholder, Message),
		         wf:flush();
		{'JOIN', _Pid} ->
			Message = [
				#p{},
				#span{text="En ny användare har anslutits:"}, 
				#span{text=wf:q(username)}
				],
				wf:insert_top(placeholder, Message),
				wf:flush(),
				repeater(Users + 1);
		{'LEAVE', _Pid} ->
				Message = [
					#p{},
					#span{text="En användare har lämnat oss"}, ":"
				
					],
				wf:insert_top(placeholder, Message);
        {msg, Msg, Username} -> 
			Message = [
				#p{},
				#span{text=Username}, ": ",
				#span{text=Msg}, "<br>"
			],
			wf:insert_top(placeholder, Message)
    end,
	?PRINT(Users),
    wf:flush(),
    repeater(Users).