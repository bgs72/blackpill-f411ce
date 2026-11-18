Perform next steps to obtain the STM32CubeClt packages:

* Download STM32CubeClt installer for Debian from https://www.st.com/en/development-tools/stm32cubeclt.html.
* Run the installer with option --keep to retain the files extracted in a temporary directory by the installer.
* Copy the Debian packages (*.deb) and the license prompt (prompt_linux_license.sh) from the temporary directory into this directory in the repo.
* Inspect the license prompt script to avoid it asking for confirmation (e.g., set the LICENSE_ALREADY_ACCEPTED=1 environment variable; see Containerfile)

Notes:

* The installer extracts the files before prompting for a license acceptance. If the installer removes the temporary directory, copy the files when the license agreement prompt is displayed, without exiting the installer. 
