import * as Joi from 'joi';

export const EnvValidationSchema = Joi.object({
    PORT: Joi.number().default(3000),
    SWAGGER_DOCS_PATH: Joi.string().required(),
});