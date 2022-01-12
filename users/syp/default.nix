{ self, ... }:
{
  age.secrets.sypPasswd.file = "${self}/secrets/passwd_syp.age";
  users.users.syp.passwordFile = "/run/agenix/sypPasswd.age";
}
