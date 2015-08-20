#!/usr/bin/env ruby
# ruby echochat.rb

$: << File.expand_path('../../lib/', __FILE__)
require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []

get '/' do
  if !request.websocket?
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
         # ws.send("Hello World!")
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
      end
      ws.onclose do
        warn("wetbsocket closed")
        settings.sockets.delete(ws)
      end
    end
  end
end

__END__
@@ index
<html>
  <body>
     <h1>What's your big website idea?</h1>
     <form id="form">
       <input type="text" id="input" placeholder="what's your big idea?"></input>
     </form>
     <div id="msgs"></div>
  </body>

  <script type="text/javascript">
  var excuses = [
    "great idea! I'll get right on implementing that to /dev/null",
    "Wow! you're a regular Stephen Jobs",
    "Nah",
    "Totally going to be the next The Facebook",
    "That'll take about 10 minutes to build the whole thing",
    "Talk to Allie",
    "I'm gonna stop you right there... What about dragon drop?",
    "Support request",
    "I'm going to swipe right on that idea",
    "You should take that idea and form a kickstarter!",
    "My nephew builds websites, that kid is a genius!",
    "Shhhh...... no tears..... just sleep.",
    "Wow! That's a great idea! Too bad someone already built it :/",
    "Hmm... I bet you can do that on Wix, try it out",
    "The ROI of this project is off the charts; I bet it's not even a natural number.",
  ]
    window.onload = function(){
      (function(){
        var show = function(el){
          return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
        }(document.getElementById('msgs'));

        var ws       = new WebSocket('ws://' + window.location.host + window.location.pathname);
        ws.onopen    = function()  { show(''); };
        ws.onclose   = function()  { show(''); }
        ws.onmessage = function(m) { show(m.data + ': ' + excuses[Math.floor(Math.random() * excuses.length)]) };

        var sender = function(f){
          var input     = document.getElementById('input');
          input.onclick = function(){ input.value = "" };
          f.onsubmit    = function(){
            ws.send(input.value);
            input.value = " ";
            return false;
          }
        }(document.getElementById('form'));
      })();
    }
  </script>
</html>
