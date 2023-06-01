#include <type/time.pat>
#include <std/mem.pat>
#include <type/magic.pat>
// BitSquid Archive magic, this depends on engine version
#define PACKAGE_HEADER_MAGIC "\x04\x00\x00\xf0"

// Game Archive or Save file
// Save files are stored as modified archives
namespace archive {
    using package_header_t;
    using save_header_t;
    using packed_data_t;
    using chunk_t;

    // Archive header
    struct header_t {
        str peek_header = std::mem::read_string($, 4);
        match (peek_header) {
            (PACKAGE_HEADER_MAGIC): package_header_t;
            (_): save_header_t save_header;
        }
    };

    // Package header
    struct package_header_t {
        type::Magic<PACKAGE_HEADER_MAGIC> magic;
    };

    // Save file header
    struct save_header_t {
        le u32 crc32 [[comment("CRC-32 of all data"), color("00000000")]];
        le u32 packed_size;
        le u32 unpacked_size;
    };

    // Achive data
    struct packed_data_t {
        le u32 unpacked_size;
        le u32 reserved;
        std::assert(
            reserved == 0,
            "invalid reserved"
        );
        chunk_t chunks[while (!std::mem::eof())];
    };

    // Data chunk, raw or zlib compressed
    struct chunk_t {
        le u32 chunk_size;
        bool compressed = chunk_size != 65536;
        char data[chunk_size];
    };

    // Archive
    struct archive_t {
        header_t header;
        packed_data_t data;
    };
}

archive::archive_t archive @ 0x00;
