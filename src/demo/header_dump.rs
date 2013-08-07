extern mod iron;

use std::str;

use iron::Env;
use iron::app::App;

fn demo(env: &Env) {
    let request = env.request;
    println(fmt!("demo received uuid: %s", request.uuid));
    println(fmt!("demo received id: %s", request.id));
    println(fmt!("demo received path: %s", request.path));

    for (k, vs) in request.headers.iter() {
        for v in vs.iter() {
            println(fmt!("demo received header: %s => %s", *k, *v));
        }
    };

    println(fmt!("demo received body: %s", str::from_bytes(request.body)));

    env.send(~"demo sent a message!\n");
}

fn index(env: &Env) {
    env.send(~"index");
}

fn main() {
    let app = App::new(Some(~"F0D32575-2ABB-4957-BC8B-12DAC8AFF13A"), ~[
        (~"^/demo$", demo),
        (~"^/$", index),
    ], ~[~"tcp://127.0.0.1:9998"], ~[~"tcp://127.0.0.1:9999"]);

    app.run();
}
