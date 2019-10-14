use std::io::ErrorKind;
use std::path::{PathBuf, Path};
use structopt::StructOpt;

mod lexer;
mod ast;

#[derive(StructOpt, Debug)]
#[structopt(name="verinject")]
pub struct Options {
    #[structopt(name = "FILE", parse(from_os_str))]
    input_file: PathBuf,
    #[structopt(name = "output", short, long)]
    output_file: Option<PathBuf>,
}

impl Options {
    fn read_cmd() -> Self {
        let mut opt = Self::from_args();
        opt.generate_defaults();
        opt
    }

    fn generate_defaults(&mut self) {
        if self.output_file.is_none() {
            self.output_file = Some(self.input_file.with_file_name(self.input_file.file_name().unwrap_or_default() + "_injected"));
        }
    }
}

fn main() -> std::io::Result<()> {
    let options = Options::read_cmd();
    let input_file = match std::fs::read_to_string(options.input_file) {
        Ok(f) => f,
        Err(e) => match e.kind() {
            ErrorKind::NotFound => {
                eprintln!("Could not find file `{}`", options.input_file);
                return Err(e);
            }
            _ => {
                eprintln!("Could not read file `{}`: {:?}", options.input_file, e);
                return Err(e);
            }
        }
    };
    Ok(())
}
