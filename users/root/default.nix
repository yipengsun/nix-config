{ self, ... }:
{
  age.secrets.rootPasswd.file = "${self}/secrets/passwd_root.age";
  users.users.root.passwordFile = "/run/agenix/rootPasswd.age";
}
