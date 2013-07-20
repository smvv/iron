extern mod zmq;
extern mod mongrel2;

use std::comm::stream;
use env::Env;

pub type CallbackFn = extern fn(&Env);
pub type Routes = ~[(~str, CallbackFn)];

/// Application
pub struct App {
    routes: ~[(~str, CallbackFn)],
    sender_id: Option<~str>,
    ctx: zmq::Context,
    conn: mongrel2::Connection,
}

/// Application

impl App {
    /// Construct a new web application
    pub fn new(sender_id: Option<~str>, routes: Routes,
               req_addrs: ~[~str], rep_addrs: ~[~str]) -> App {
        let ctx = match zmq::init(1) {
            Ok(ctx) => ctx,
            Err(e) => fail!(e.to_str()),
        };

        let conn = mongrel2::connect(ctx, sender_id.clone(), req_addrs,
                                     rep_addrs);

        App {routes: routes, sender_id: sender_id, ctx: ctx, conn: conn}
    }

    /// Start the main loop of a web application
    pub fn run(&self) {
        //vec::each(self.routes, |&route| {
        //    let (pattern, callback) = route;

        //    println(fmt!("%s -> %s", pattern, self.spawn(callback)));

        //    true
        //});

        println("Entering mongrel2 event loop");

        loop {
            self.heartbeat();
        }
    }

    /// Trigger a single heartbeat of a web application's main loop.
    pub fn heartbeat(&self) {
        match self.conn.recv() {
            Ok(request) => {
                self.spawn(request);
            }
            Err(error) => {
                error!("heartbeat caught an error: %s", error);
            }
        }
    }

    fn spawn(&self, request: mongrel2::Request) {
        let (_, callback) = self.routes[0];

        let (port, chan) : (Port<~str>, Chan<~str>) = stream();

        let env_request = request.clone();

        do spawn {
            callback(~Env {
                out_ch: &chan,
                request: &env_request,
            });
        }

        // TODO call port.recv() until port is closed?
        let rep_body = port.recv();
        let headers = mongrel2::Headers();

        self.conn.reply_http(&request, 200u, "OK", headers, rep_body);
    }
}
