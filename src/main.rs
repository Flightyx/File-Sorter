use std::collections::HashMap;
use std::env::args;
use std::fs;
use std::io;

/* - Things that im planing on implementing:
 * - folder names for extensions should be user decision
 * - fix bug where only file paths that end on / work
 * - when two names are identical the user should decide whether to, overwrite, change name to have suffix (1) or dont move the file
 * - add help page
 */
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let working_directory: String = args().nth(1).expect("Error while reading cli arguments"); //only works when path ends with /
    //let working_directory: String = String::from("/home/michael/Downloads/"); //testing purposes only
    println!(
        "[DEBUG] Successfully registered working_directory {}",
        &working_directory
    );
    let mut found_files: Vec<[String; 2]> = vec![];
    let mut found_file_extensions: Vec<String> = vec![];
    let mut names_for_file_extension_folder = HashMap::new();

    for file in fs::read_dir(&working_directory)? {
        let file = file?;
        let path = file.path();

        let file_name = path
            .file_name()
            .unwrap_or_default()
            .to_string_lossy()
            .into_owned();
        println!(
            "\n[DEBUG] Successfully registered file or directory: {}",
            file_name
        );

        let extension = path
            .extension()
            .unwrap_or_default()
            .to_string_lossy()
            .into_owned();
        println!(
            "[DEBUG] Successfully registered file extension: {}",
            extension
        );

        if extension != "" {
            if !found_file_extensions.contains(&extension) {
                found_file_extensions.push(extension.clone());
            }
        }

        let tmp_found_files: [String; 2] = [file_name, extension];
        found_files.push(tmp_found_files);
        println!(
            "[DEBUG] Successfully added file and it's extension to global found_files variable"
        );
    }
    println!("\n\n\n");
    for extension in found_file_extensions {
        let mut user_in: String = String::new();
        println!(
            "What should the folder with all files with the extension '{}' be called?:",
            &extension
        );
        io::stdin()
            .read_line(&mut user_in)
            .expect("[ERROR] Error while reading user input");
        names_for_file_extension_folder.insert(extension, user_in.trim().to_string());
    }
    println!(
        "\n[DEBUG] Registered all folder names for all extensions: {:?}",
        names_for_file_extension_folder
    );
    println!("\n\n\n");
    for i in found_files {
        if &*i[1] != "" {
            println!("\n[DEBUG] Processing file {}", &*i[0]);
            let new_dir_path = format!(
                "{}{}",
                &working_directory,
                names_for_file_extension_folder.get(&*i[1]).unwrap()
            );
            let new_file_path = format!("{}/{}", &new_dir_path, &*i[0]);
            let file_path = format!("{}{}", &working_directory, &*i[0]);
            println!("[DEBUG] new_file_path will be: {}", &new_file_path);

            fs::create_dir_all(&new_dir_path)?;
            println!("[DEBUG] Created directory: {}", &new_dir_path);
            fs::rename(file_path, &new_file_path)?;
            println!("[DEBUG] Moved file: {} to: {}", &*i[0], &new_dir_path);
        } else {
            println!("\n[DEBUG] Finished processing directory: {:?}", &i);
        }
    }

    println!("\nFinished cleanup!");

    Ok(())
}
