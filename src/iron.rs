#[link(name="iron", vers="0.1pre",
       uuid="1abdbcd0-ba92-11e2-9e96-0800200c9a66")];

#[crate_type="lib"];

pub mod app;
pub mod env;

pub type Env <'self> = env::Env <'self>;
