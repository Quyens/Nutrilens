//
//  VietnameseDishIngredientMetadata.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Documented reference ingredients and potential allergen indicators based on
//  Viện Dinh Dưỡng Quốc Gia (NIN) and Vietnamese Culinary Guidelines.
//  IMPORTANT: Represents documented reference data only, NOT laboratory testing.
//

import Foundation

public struct DishIngredientInfo: Sendable {
    public let slug: String
    public let documentedIngredients: [String]
    public let allergens: [AllergenType]
    public let typicalMealCategories: [PlannedMealCategory]
    public let isVegetarian: Bool
    public let isPescatarian: Bool
    public let verificationStatus: IngredientVerificationStatus

    public init(
        slug: String,
        documentedIngredients: [String],
        allergens: [AllergenType],
        typicalMealCategories: [PlannedMealCategory],
        isVegetarian: Bool = false,
        isPescatarian: Bool = false,
        verificationStatus: IngredientVerificationStatus = .verified
    ) {
        self.slug = slug
        self.documentedIngredients = documentedIngredients
        self.allergens = allergens
        self.typicalMealCategories = typicalMealCategories
        self.isVegetarian = isVegetarian
        self.isPescatarian = isPescatarian
        self.verificationStatus = verificationStatus
    }
}

public enum VietnameseDishIngredientMetadata {
    private static let metadataMap: [String: DishIngredientInfo] = [
        "pho": DishIngredientInfo(
            slug: "pho",
            documentedIngredients: [
                "Bánh phở (bột gạo)",
                "Thịt bò tái/nạm",
                "Nước hầm xương bò",
                "Hành hoa & ngò gai",
                "Gừng nướng, quế, thảo quả",
                "Nước mắm truyền thống"
            ],
            allergens: [.fish],
            typicalMealCategories: [.breakfast, .dinner]
        ),
        "com_tam": DishIngredientInfo(
            slug: "com_tam",
            documentedIngredients: [
                "Gạo tấm",
                "Sườn cốt lết heo nướng",
                "Chả trứng (trứng, nấm mèo, thịt xay)",
                "Bì heo thính",
                "Mỡ hành",
                "Nước mắm chua ngọt"
            ],
            allergens: [.eggs, .fish],
            typicalMealCategories: [.lunch, .dinner]
        ),
        "bun_bo_hue": DishIngredientInfo(
            slug: "bun_bo_hue",
            documentedIngredients: [
                "Bún tươi sợi tròn to",
                "Nạm bò & bắp bò",
                "Móng giò heo",
                "Chả cua Huế",
                "Mắm ruốc Huế",
                "Sả cây, ớt bột",
                "Nước mắm"
            ],
            allergens: [.shellfish, .fish],
            typicalMealCategories: [.breakfast, .lunch]
        ),
        "banh_mi": DishIngredientInfo(
            slug: "banh_mi",
            documentedIngredients: [
                "Bánh mì baguette (bột mì, men nở)",
                "Pate gan heo",
                "Thịt nguội & chả lụa",
                "Dưa leo, đồ chua cà rốt",
                "Ngò rí",
                "Nước tương / sốt thịt"
            ],
            allergens: [.gluten, .soy],
            typicalMealCategories: [.breakfast, .snack]
        ),
        "goi_cuon": DishIngredientInfo(
            slug: "goi_cuon",
            documentedIngredients: [
                "Bánh tráng gạo mỏng",
                "Tôm sú luộc",
                "Thịt ba chỉ luộc",
                "Bún tươi",
                "Rau hẹ & xà lách",
                "Tương đen chấm (đậu phộng rang, tương đậu nành)"
            ],
            allergens: [.shellfish, .peanuts, .soy],
            typicalMealCategories: [.snack, .lunch, .dinner]
        ),
        "banh_beo": DishIngredientInfo(
            slug: "banh_beo",
            documentedIngredients: [
                "Bột gạo & bột năng hấp",
                "Tôm chấy giã nhuyễn",
                "Da heo chiên giòn",
                "Mỡ hành",
                "Nước mắm pha loãng chua ngọt"
            ],
            allergens: [.shellfish, .fish],
            typicalMealCategories: [.snack, .breakfast]
        ),
        "banh_bot_loc": DishIngredientInfo(
            slug: "banh_bot_loc",
            documentedIngredients: [
                "Bột năng luộc trong suốt",
                "Tôm sông rim đậm đà",
                "Thịt ba chỉ thái hạt lựu",
                "Hành hoa phi mỡ",
                "Nước mắm mặn ớt xiêm"
            ],
            allergens: [.shellfish, .fish],
            typicalMealCategories: [.snack, .lunch]
        ),
        "banh_can": DishIngredientInfo(
            slug: "banh_can",
            documentedIngredients: [
                "Bột gạo nướng khuôn đất",
                "Trứng cút / Trứng gà ta",
                "Mực ống / Tôm tươi",
                "Mỡ hành",
                "Nước chấm xíu mại cá/nước mắm"
            ],
            allergens: [.eggs, .shellfish, .fish],
            typicalMealCategories: [.breakfast, .dinner, .snack]
        ),
        "banh_canh": DishIngredientInfo(
            slug: "banh_canh",
            documentedIngredients: [
                "Sợi bánh canh bột lọc/gạo",
                "Chả cá thác lác chiên",
                "Tôm tươi & thịt nạc",
                "Nước hầm xương heo đậm đà",
                "Hành lá & tiêu đen"
            ],
            allergens: [.fish, .shellfish],
            typicalMealCategories: [.breakfast, .lunch, .dinner]
        ),
        "banh_chung": DishIngredientInfo(
            slug: "banh_chung",
            documentedIngredients: [
                "Gạo nếp cái hoa vàng",
                "Đậu xanh đồ chín bùi",
                "Thịt ba chỉ heo tiêu ướp",
                "Hạt tiêu đen xay",
                "Lá dong tươi gói"
            ],
            allergens: [],
            typicalMealCategories: [.breakfast, .lunch]
        ),
        "banh_cuon": DishIngredientInfo(
            slug: "banh_cuon",
            documentedIngredients: [
                "Bánh tráng bột gạo tráng hơi nước",
                "Thịt nạc vai heo băm",
                "Mộc nhĩ & nấm hương",
                "Hành khô phi vàng giòn",
                "Chả quế / Chả lụa",
                "Nước mắm pha ấm"
            ],
            allergens: [.fish],
            typicalMealCategories: [.breakfast, .dinner]
        ),
        "banh_duc": DishIngredientInfo(
            slug: "banh_duc",
            documentedIngredients: [
                "Bột gạo pha bột năng quấy dẻo",
                "Thịt heo nạc băm xào mộc nhĩ",
                "Rau mùi ta (ngò rí)",
                "Hành khô phi giòn",
                "Nước mắm chan ấm thanh ngọt"
            ],
            allergens: [.fish],
            typicalMealCategories: [.snack, .breakfast]
        ),
        "banh_gio": DishIngredientInfo(
            slug: "banh_gio",
            documentedIngredients: [
                "Bột gạo tẻ và bột năng nhào dẻo",
                "Thịt nạc vai heo băm nhỏ",
                "Mộc nhĩ, nấm mèo thái chỉ",
                "Trứng cút luộc",
                "Hạt tiêu thơm, gói lá chuối"
            ],
            allergens: [.eggs],
            typicalMealCategories: [.breakfast, .snack]
        ),
        "banh_khot": DishIngredientInfo(
            slug: "banh_khot",
            documentedIngredients: [
                "Bột gạo chiên giòn rụm",
                "Nước cốt dừa thơm béo",
                "Tôm tươi nõn",
                "Mỡ hành & bột tôm chấy",
                "Nước mắm tỏi ớt, rau cải non"
            ],
            allergens: [.shellfish, .fish],
            typicalMealCategories: [.lunch, .dinner, .snack]
        ),
        "banh_pia": DishIngredientInfo(
            slug: "banh_pia",
            documentedIngredients: [
                "Bột mì cán nhiều lớp da mỏng",
                "Đậu xanh xay nhuyễn tán mịn",
                "Cơm sầu riêng tươi",
                "Lòng đỏ trứng vịt muối",
                "Mỡ đường truyền thống"
            ],
            allergens: [.gluten, .eggs],
            typicalMealCategories: [.snack]
        ),
        "banh_tet": DishIngredientInfo(
            slug: "banh_tet",
            documentedIngredients: [
                "Gạo nếp dẻo thơm miền Tây",
                "Đậu xanh cà vỏ đồ nhuyễn",
                "Thịt ba rọi heo ướp tiêu",
                "Lá chuối xiêm gói đòn tròn"
            ],
            allergens: [],
            typicalMealCategories: [.breakfast, .lunch]
        ),
        "banh_trang_nuong": DishIngredientInfo(
            slug: "banh_trang_nuong",
            documentedIngredients: [
                "Bánh tráng gạo mỏng nướng than",
                "Trứng cút đánh đều",
                "Tép khô / Ruốc khô xào cay",
                "Thịt băm xào hành lá",
                "Bơ thực vật & Sốt mayonnaise",
                "Tương ớt cay nồng"
            ],
            allergens: [.eggs, .shellfish, .milk],
            typicalMealCategories: [.snack]
        ),
        "banh_xeo": DishIngredientInfo(
            slug: "banh_xeo",
            documentedIngredients: [
                "Bột gạo nghệ vàng óng giòn rụm",
                "Nước cốt dừa béo thanh",
                "Tôm sú tươi nguyên con",
                "Thịt ba chỉ heo thái mỏng",
                "Giá đỗ non, hành lá",
                "Nước mắm chua ngọt, rau rừng"
            ],
            allergens: [.shellfish, .fish],
            typicalMealCategories: [.lunch, .dinner]
        ),
        "bun_dau_mam_tom": DishIngredientInfo(
            slug: "bun_dau_mam_tom",
            documentedIngredients: [
                "Bún lá tươi cắt miếng",
                "Đậu phụ Mơ chiên vàng giòn",
                "Thịt chân giò luộc thái mỏng",
                "Chả cốm Hà Nội rán",
                "Mắm tôm Thanh Hóa đánh sủi bọt quất",
                "Rau kinh giới, tía tô"
            ],
            allergens: [.shellfish, .soy],
            typicalMealCategories: [.lunch, .dinner]
        ),
        "bun_mam": DishIngredientInfo(
            slug: "bun_mam",
            documentedIngredients: [
                "Bún tươi miền Tây",
                "Nước lèo mắm cá linh & mắm cá sặc",
                "Tôm sú tươi luộc",
                "Mực ống thái khoanh",
                "Thịt heo quay giòn da",
                "Cà tím, sả băm",
                "Rau đắng, bông súng, giá sống"
            ],
            allergens: [.fish, .shellfish],
            typicalMealCategories: [.lunch, .dinner]
        ),
        "bun_rieu": DishIngredientInfo(
            slug: "bun_rieu",
            documentedIngredients: [
                "Bún tươi sợi nhỏ",
                "Gạch cua đồng giã nhuyễn đóng bánh",
                "Cà chua xào dầu điều",
                "Đậu phụ chiên giòn",
                "Mắm tôm & giấm bỗng chua dịu",
                "Huyết heo luộc",
                "Rau muống chẻ, hoa chuối bào"
            ],
            allergens: [.shellfish, .soy],
            typicalMealCategories: [.breakfast, .lunch]
        ),
        "bun_thit_nuong": DishIngredientInfo(
            slug: "bun_thit_nuong",
            documentedIngredients: [
                "Bún tươi",
                "Thịt heo nạc ướp sả ớt nướng than hoa",
                "Đậu phộng rang giã dập",
                "Mỡ hành lá",
                "Đồ chua củ cải cà rốt",
                "Nước mắm tỏi ớt chua ngọt"
            ],
            allergens: [.peanuts, .fish],
            typicalMealCategories: [.lunch, .dinner]
        ),
        "ca_kho_to": DishIngredientInfo(
            slug: "ca_kho_to",
            documentedIngredients: [
                "Cá lóc đồng / Cá ba sa tươi cắt khúc",
                "Nước mắm cốt cá cơm Phú Quốc",
                "Nước hàng đường thốt nốt",
                "Hạt tiêu đen sọ giã thô",
                "Hành tím phi, ớt hiểm đỏ"
            ],
            allergens: [.fish],
            typicalMealCategories: [.lunch, .dinner],
            isPescatarian: true
        ),
        "canh_chua": DishIngredientInfo(
            slug: "canh_chua",
            documentedIngredients: [
                "Cá lóc bông / Khúc cá hồi",
                "Quả dứa (thơm) thái lát",
                "Cà chua múi cau",
                "Dọc mùng (bạc hà) tước vỏ",
                "Đậu bắp non thái vát",
                "Giá đỗ sạch",
                "Nước cốt me chua thanh",
                "Ngò gai & ngò om (rau ngổ)",
                "Nước mắm nguyên chất"
            ],
            allergens: [.fish],
            typicalMealCategories: [.lunch, .dinner],
            isPescatarian: true
        ),
        "cao_lau": DishIngredientInfo(
            slug: "cao_lau",
            documentedIngredients: [
                "Mì Cao Lầu Hội An sợi dẻo tro củi",
                "Thịt heo xíu thơm ngũ vị hương",
                "Tép mỡ chiên giòn rụm",
                "Nước sốt thịt xíu đậm đà",
                "Nước tương đậu nành",
                "Rau thơm Trà Quế & húng lủi"
            ],
            allergens: [.soy],
            typicalMealCategories: [.lunch, .dinner]
        ),
        "chao_long": DishIngredientInfo(
            slug: "chao_long",
            documentedIngredients: [
                "Gạo tẻ & nếp rang thơm nấu nhừ",
                "Nước hầm xương heo ngọt tủy",
                "Lòng non, dồi huyết heo luộc",
                "Gan heo, dạ dày luộc",
                "Hành hoa, tiêu sọ, gừng thái chỉ"
            ],
            allergens: [],
            typicalMealCategories: [.breakfast, .dinner, .snack]
        ),
        "hu_tieu": DishIngredientInfo(
            slug: "hu_tieu",
            documentedIngredients: [
                "Sợi hủ tiếu dai Sa Đéc",
                "Tôm thẻ bóc vỏ rim",
                "Thịt nạc băm viên nhỏ",
                "Gan heo luộc & trứng cút",
                "Tỏi phi giòn thơm",
                "Hẹ lá, cần tây thái khúc"
            ],
            allergens: [.shellfish, .eggs],
            typicalMealCategories: [.breakfast, .dinner]
        ),
        "mi_quang": DishIngredientInfo(
            slug: "mi_quang",
            documentedIngredients: [
                "Bánh tráng mì Quảng sợi vàng nghệ",
                "Tôm sông rim mặn ngọt",
                "Thịt ba chỉ heo rim ngũ vị",
                "Trứng cút kho",
                "Đậu phộng rang vàng đập dập",
                "Bánh tráng mè nướng giòn rụm",
                "Rau bắp chuối, rau thơm Trà Quế"
            ],
            allergens: [.shellfish, .eggs, .peanuts, .sesame],
            typicalMealCategories: [.breakfast, .lunch]
        ),
        "nem_chua": DishIngredientInfo(
            slug: "nem_chua",
            documentedIngredients: [
                "Thịt nạc mông heo tươi quết dẻo",
                "Bì heo thái chỉ sợi mảnh",
                "Thính gạo rang mịn",
                "Tỏi tươi thái lát",
                "Ớt đỏ & lá đinh lăng tươi lên men"
            ],
            allergens: [],
            typicalMealCategories: [.snack]
        ),
        "xoi": DishIngredientInfo(
            slug: "xoi",
            documentedIngredients: [
                "Gạo nếp cái hoa vàng đồ chín dẻo",
                "Đậu xanh cà vỏ hấp mềm tán nhuyễn",
                "Hành củ phi mỡ vàng thơm",
                "Muối vừng (mè rang và muối hầm)"
            ],
            allergens: [.sesame],
            typicalMealCategories: [.breakfast, .snack],
            isVegetarian: true
        ),
        "bun_cha": DishIngredientInfo(
            slug: "bun_cha",
            documentedIngredients: [
                "Bún tươi sợi mảnh Hà Nội",
                "Chả băm thịt nạc vai ướp hành tiêu",
                "Chả miếng thịt ba chỉ nướng than hoa",
                "Đu đủ & cà rốt ngâm giấm đường",
                "Nước mắm pha ấm vị thanh",
                "Tỏi, ớt băm, xà lách, tía tô"
            ],
            allergens: [.fish],
            typicalMealCategories: [.lunch, .dinner]
        ),
        "com_ga": DishIngredientInfo(
            slug: "com_ga",
            documentedIngredients: [
                "Gạo tẻ nấu nước luộc gà mỡ nghệ thơm",
                "Thịt gà ta thả vườn xé phay",
                "Hành tây thái mỏng ngâm giấm",
                "Rau răm thơm bùi",
                "Nước mắm gừng ớt tỏi"
            ],
            allergens: [.fish],
            typicalMealCategories: [.lunch, .dinner]
        ),
        "cha_gio": DishIngredientInfo(
            slug: "cha_gio",
            documentedIngredients: [
                "Bánh tráng gạo nem rế",
                "Thịt nạc vai heo xay",
                "Tôm tươi băm hạt lựu",
                "Miến dong thái khúc nhỏ",
                "Mộc nhĩ, nấm hương, cà rốt",
                "Trứng gà tươi trộn nhân",
                "Nước mắm chua ngọt chấm kèm"
            ],
            allergens: [.shellfish, .eggs, .fish],
            typicalMealCategories: [.lunch, .dinner, .snack]
        ),
        "bo_kho": DishIngredientInfo(
            slug: "bo_kho",
            documentedIngredients: [
                "Nạm bò & gân bò ninh mềm",
                "Cà rốt tươi cắt khúc hoa",
                "Sả cây đập dập thơm lừng",
                "Hoa hồi, quế chi, thảo quả",
                "Dầu màu điều tạo sắc",
                "Ăn kèm bánh mì baguette (bột mì)"
            ],
            allergens: [.gluten],
            typicalMealCategories: [.breakfast, .lunch, .dinner]
        ),
        "che_dau_do": DishIngredientInfo(
            slug: "che_dau_do",
            documentedIngredients: [
                "Đậu đỏ hạt căng tròn ninh bở mềm",
                "Đường phèn tự nhiên thanh ngọt",
                "Nước cốt dừa tươi nguyên chất",
                "Bột báng dai mềm dẻo",
                "Chiết xuất vani tự nhiên"
            ],
            allergens: [],
            typicalMealCategories: [.snack],
            isVegetarian: true,
            isPescatarian: true
        )
    ]

    public static func metadata(forSlug slug: String) -> DishIngredientInfo? {
        let normalized = slug.replacingOccurrences(of: "-", with: "_").lowercased()
        return metadataMap[normalized]
    }

    public static func allMetadata() -> [DishIngredientInfo] {
        Array(metadataMap.values)
    }
}

