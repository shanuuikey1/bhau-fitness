using System;
using System.Security.Cryptography;
using Microsoft.AspNetCore.Identity;
using Isopoh.Cryptography.Argon2;

namespace BhauFitnessApi.Services
{
    /// <summary>
    /// Argon2id password hasher for high‑security password storage.
    /// Uses the Isopoh.Argon2 library (available on NuGet) and a per‑user salt.
    /// </summary>
    public class Argon2PasswordHasher<TUser> : IPasswordHasher<TUser> where TUser : class
    {
        // Recommended parameters for Argon2id (see OWASP).
        private const int SaltSize = 16; // 128‑bit salt
        private const int HashSize = 32; // 256‑bit hash
        private const int Iterations = 4; // Number of passes (t)
        private const int MemorySize = 1 << 16; // 64 MiB (m)
        private const int DegreeOfParallelism = 2; // p

        public string HashPassword(TUser user, string password)
        {
            // Generate a cryptographically strong random salt.
            var salt = new byte[SaltSize];
            RandomNumberGenerator.Fill(salt);

            var hash = ComputeHash(password, salt);

            // Store in the format: $argon2id$v=19$m=65536,t=4,p=2$<base64(salt)>$<base64(hash)>
            var encoded = $"$argon2id$v=19$m={MemorySize},t={Iterations},p={DegreeOfParallelism}$" +
                           Convert.ToBase64String(salt) + "$" +
                           Convert.ToBase64String(hash);
            return encoded;
        }

        public PasswordVerificationResult VerifyHashedPassword(TUser user, string hashedPassword, string providedPassword)
        {
            try
            {
                // Expected format: $argon2id$v=19$m=...,t=...,p=...$<salt>$<hash>
                var parts = hashedPassword.Split('$', StringSplitOptions.RemoveEmptyEntries);
                if (parts.Length != 5 || !parts[0].StartsWith("argon2id"))
                    return PasswordVerificationResult.Failed;

                // Salt and hash are base64‑encoded.
                var salt = Convert.FromBase64String(parts[3]);
                var expectedHash = Convert.FromBase64String(parts[4]);

                var actualHash = ComputeHash(providedPassword, salt);
                return CryptographicOperations.FixedTimeEquals(actualHash, expectedHash)
                    ? PasswordVerificationResult.Success
                    : PasswordVerificationResult.Failed;
            }
            catch
            {
                // Any parsing error is treated as a failure.
                return PasswordVerificationResult.Failed;
            }
        }

        private static byte[] ComputeHash(string password, byte[] salt)
{
    var config = new Argon2Config
    {
        Type = Argon2Type.DataIndependentAddressing,
        Version = Argon2Version.Nineteen,
        TimeCost = Iterations,
        MemoryCost = MemorySize,
        Lanes = DegreeOfParallelism,
        Threads = DegreeOfParallelism,
        Password = System.Text.Encoding.UTF8.GetBytes(password),
        Salt = salt,
        HashLength = HashSize
    };
    using var argon2 = new Argon2(config);
    return argon2.Hash().Buffer;
}
    }
}
