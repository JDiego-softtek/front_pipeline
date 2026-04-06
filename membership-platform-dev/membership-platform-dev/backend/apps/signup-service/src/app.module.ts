import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { join } from 'path';
import { EnvConfig, EnvValidationSchema, ServiceConfig } from '../config';
const { path } = ServiceConfig;

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: join(process.cwd(), 'apps', path, '.env'),
      load: [EnvConfig],
      validationSchema: EnvValidationSchema,
    }),
  ],
})
export class AppModule { }
