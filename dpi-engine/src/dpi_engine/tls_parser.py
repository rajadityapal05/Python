from scapy.layers.inet import TCP


class TLSParser:

    @staticmethod
    def extract_sni(packet):
        if not packet.haslayer(TCP):
            return None

        payload = bytes(packet[TCP].payload)

        if len(payload) < 5:
            return None

        # TLS record:
        # Content Type  = 1 byte
        # Version       = 2 bytes
        # Length        = 2 bytes
        if payload[0] != 0x16:
            return None

        record_length = int.from_bytes(payload[3:5], "big")

        if len(payload) < 5 + record_length:
            return None

        # TLS handshake:
        # Handshake Type = 1 byte
        # Length         = 3 bytes
        if payload[5] != 0x01:
            return None

        hello_start = 5

        if len(payload) < hello_start + 4:
            return None

        hello_length = int.from_bytes(
            payload[hello_start + 1:hello_start + 4],
            "big"
        )

        hello_end = hello_start + 4 + hello_length

        if hello_end > len(payload):
            return None

        offset = hello_start + 4

        # ClientHello:
        # Version: 2 bytes
        # Random: 32 bytes
        if offset + 34 > hello_end:
            return None

        offset += 2
        offset += 32

        # Session ID
        if offset + 1 > hello_end:
            return None

        session_id_length = payload[offset]
        offset += 1

        if offset + session_id_length > hello_end:
            return None

        offset += session_id_length

        # Cipher suites
        if offset + 2 > hello_end:
            return None

        cipher_suites_length = int.from_bytes(
            payload[offset:offset + 2],
            "big"
        )
        offset += 2

        if offset + cipher_suites_length > hello_end:
            return None

        offset += cipher_suites_length

        # Compression methods
        if offset + 1 > hello_end:
            return None

        compression_length = payload[offset]
        offset += 1

        if offset + compression_length > hello_end:
            return None

        offset += compression_length

        # Extensions may be absent.
        if offset + 2 > hello_end:
            return None

        extensions_length = int.from_bytes(
            payload[offset:offset + 2],
            "big"
        )
        offset += 2

        extensions_end = min(
            offset + extensions_length,
            hello_end
        )

        # Walk through TLS extensions.
        while offset + 4 <= extensions_end:

            extension_type = int.from_bytes(
                payload[offset:offset + 2],
                "big"
            )

            extension_length = int.from_bytes(
                payload[offset + 2:offset + 4],
                "big"
            )

            offset += 4

            if offset + extension_length > extensions_end:
                return None

            extension_data = payload[
                offset:offset + extension_length
            ]

            # Server Name extension
            if extension_type == 0x0000:

                # ServerNameList length: 2 bytes
                if len(extension_data) < 2:
                    return None

                sni_offset = 2

                while sni_offset + 3 <= len(extension_data):

                    name_type = extension_data[sni_offset]
                    name_length = int.from_bytes(
                        extension_data[
                            sni_offset + 1:sni_offset + 3
                        ],
                        "big"
                    )

                    sni_offset += 3

                    if (
                        sni_offset + name_length
                        > len(extension_data)
                    ):
                        return None

                    # 0 = host_name
                    if name_type == 0x00:
                        hostname = extension_data[
                            sni_offset:
                            sni_offset + name_length
                        ].decode(
                            "ascii",
                            errors="ignore"
                        ).strip().lower()

                        return hostname or None

                    sni_offset += name_length

            offset += extension_length

        return None
