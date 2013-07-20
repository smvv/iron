extern mod mongrel2;

pub struct Env <'self> {
    out_ch: &'self Chan<~str>,
    request: &'self mongrel2::Request,
}

impl <'self> Env <'self> {
    pub fn send <'t> (&'t self, msg: ~str) {
        self.out_ch.send(msg);
    }
}
