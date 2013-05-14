pub struct Env <'self> {
    out_ch: &'self Chan<~str>,
}

pub impl <'self> Env <'self> {
    fn send <'t> (&'t self, msg: ~str) {
        self.out_ch.send(msg);
    }
}
