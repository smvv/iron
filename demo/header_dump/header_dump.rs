extern mod iron;
use iron::{Env, app};

fn demo(env: &Env) {
    env.send(~"demo");
}

fn index(env: &Env) {
    env.send(~"index");
}

fn main() {
    let app = app(~[
        (~"^/demo$", demo),
        (~"^/$", index),
    ]);

    app.run();
}
