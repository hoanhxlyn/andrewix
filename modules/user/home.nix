{username, stateVersion, ...}@inputs:
{
	imports = [
		./bundle.nix
	];
	home = {
	# Do not override var here
		inherit username stateVersion;
		homeDirectory = "/home/${username}";
	};
	gtk = {
		enable = true;
		font = {
			name = "${inputs.fontFamily}";
			size = 12;
		};
	};
}
