use env::Env;

use core::comm::stream;

pub type CallbackFn = extern fn(&Env);

pub struct App {
    routes: ~[(~str, CallbackFn)],
}

pub impl App {
    fn run(&self) {
        vec::each(self.routes, |&route| {
            let (pattern, callback) = route;

            io::println(fmt!("%s -> %s", pattern, self.spawn(callback)));

            true
        });
    }

    fn spawn(&self, callback: CallbackFn) -> ~str {
        let (port, chan) : (Port<~str>, Chan<~str>) = stream();

        do spawn {
            let env = ~Env { out_ch: &chan };
            callback(env);
        }

        port.recv()
    }
}
