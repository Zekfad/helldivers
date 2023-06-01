#pragma pattern_limit 100000000
#pragma array_limit 100000000

#include <std/mem.pat>
#include <type/magic.pat>

// Save file
// Actually a dumped Lua table

// Save
namespace save {
    // needed for sanity check
    u128 _total_size = 0;
    using table_t;
    using _table_end_t;
    using _table_pair_t;
    using float_t;
    using string_t;
    using bool_t;
    using vec3_t;
    using vec3box_t;
    using mat4x4_t;
    using mat4x4box_t;
    using double_t;

    // Entry type
    enum Type: u32 {
        TableBegin   = 0x0,
        TableEnd     = 0x1,
        Float        = 0x2,
        String       = 0x3,
        Bool         = 0x4,
        Vector3      = 0x5,
        Vector3Box   = 0x6,
        Matrix4x4    = 0x7,
        Matrix4x4Box = 0x8,
        Double       = 0x9,
    };

    // Entry
    struct entry_t {
        std::mem::AlignTo<4>;
        le Type type;

        match (type) {
            (Type::TableBegin):      table_t value;
            (Type::TableEnd):        _table_end_t value;
            (Type::Float):           float_t value;
            (Type::String):          string_t value;
            (Type::Bool):            bool_t value;
            (Type::Vector3):         vec3_t value;
            (Type::Vector3Box):      vec3box_t value;
            (Type::Matrix4x4):       mat4x4_t value;
            (Type::Matrix4x4Box):    mat4x4box_t value;
            (Type::Double):          double_t value;
        }
    };

    // Type::TableBegin
    // Table
    struct table_t {
        _table_pair_t entries[while(
            $ < _total_size &&
            std::mem::read_unsigned($, sizeof(Type)) != Type::TableEnd
        )];
        Type end;
        std::assert(
            end == Type::TableEnd,
            "Expected table end."
        );
    };

    // Type::TableEnd
    // Table end
    struct _table_end_t {};

    // Table contents pair
    struct _table_pair_t {
        entry_t value;
        entry_t key;
    };

    // Type::Float
    // 32-bit float
    struct float_t {
        std::print("UNIMPLEMENTD: float {}", $);
    };

    // Type::String
    // String
    struct string_t {
        std::mem::AlignTo<4>;
        le u32 size;
        char string[size];
    };

    // Type::Bool
    // Boolean
    struct bool_t {
        std::mem::AlignTo<4>;
        le bool value;
        padding[3];
    };

    // Type::Vector3
    struct vec3_t {
        std::print("UNIMPLEMENTD: vec3 {}", $);
    };

    // Type::Vector3Box
    struct vec3box_t {
        std::print("UNIMPLEMENTD: vec3box {}", $);
    };

    // Type::Matrix4x4
    struct mat4x4_t {
        std::print("UNIMPLEMENTD: mat4x4 {}", $);
    };

    // Type::Matrix4x4Box
    struct mat4x4box_t {
        std::print("UNIMPLEMENTD: mat4x4box {}", $);
    };
    
    // Type::Double
    // 64-bit float
    struct double_t {
        std::mem::AlignTo<8>;
        le double value;
    };

    // Save
    struct save_t {
        le u32 size;
        _total_size = size;
        le u32 unknown1;
        le u32 unknown2;
        le u32 unknown3;

        entry_t data;
    };
}

save::save_t save @ 0;
